{{/* Drupal container spec */}}
{{ define "common.deployment.lifecyle.preStop" }}
exec:
  command: ["sleep", {{ .Values.gracefulUpdate.preStopTimeout | quote }}]
{{- end }}

{{ define "drupal.deployment.containerSpec" }}
{{ include "drupal.commonSpec" . -}}
  lifecycle:
    preStop:
    {{- include "common.deployment.lifecyle.preStop" . | indent 6 }}
  livenessProbe:
    tcpSocket:
      port: fastcgi
    initialDelaySeconds: 15
    periodSeconds: 10
    timeoutSeconds: 5
    failureThreshold: 8
  resources:
  {{- include "drupal.app.resources" . | indent 4 }}
{{ end }}
{{ define "drupal.cron.containerSpec" }}
{{ include "drupal.commonSpec" . -}}
  command: ["/bin/bash"]
  args:
    - "-c"
    - "drush cron"
  resources:
  {{- include "drupal.cron.resources" . | indent 4 }}
{{ end }}

{{ define "drupal.backupJob.containerSpec" -}}
{{ include "drupal.commonSpec" . -}}
  # @todo: Chugging it into some object storage like minio would be better probably.
  command: ["/bin/bash"]
  args:
    - "-c"
    - "STAMP=$(date +%F_%I-%M-%S); drush sql-dump --result-file=/backups/db-backup.${STAMP}.sql --gzip && cp /backups/db-backup.${STAMP}.sql.gz /backups/db-backup.latest.sql.gz"
  resources:
  {{- include "drupal.backupJob.resources" . | indent 4 }}
{{ end }}

{{- define "drupal.backupRestoreJob.backupFile" -}}
/backups/db-backup.{{- .Values.rollback.backupVersion | default "latest" -}}.sql
{{- end -}}

{{ define "drupal.backupRestoreJob.containerSpec" -}}
{{ include "drupal.commonSpec" . -}}
  command: ["/bin/bash"]
  args:
    - "-c"
    - "gunzip -fk {{ include "drupal.backupRestoreJob.backupFile" . -}}.gz && cd /var/www/html && drush sql:drop -y && drush sqlc < {{ include "drupal.backupRestoreJob.backupFile" . }} && rm {{ include "drupal.backupRestoreJob.backupFile" . -}}"
  resources:
  {{- include "drupal.backupRestoreJob.resources" . | indent 4 }}
{{ end }}

{{ define "drupal.deployJob.containerSpec" -}}
{{ include "drupal.commonSpec" . -}}
  command: ["/bin/bash"]
  args:
    - "-c"
    - "drush deploy"
  resources:
  {{- include "drupal.deployJob.resources" . | indent 4 }}
{{ end }}

{{ define "drupal.commonSpec" }}
- image: {{ .Values.drupalImage }}
  imagePullPolicy: {{ .Values.imagePullPolicy }}
  name: drupal
  {{/* @todo: Add and test these for enchanced security.
  @todo: Add the equivalent to the nginx image.
  @todo: Allow controlling these via values.yaml
  securityContext:
    privileged: false
    allowPrivilegeEscalation: false
    runAsNonRoot: true
    runAsUser: 1000
    runAsGroup: 1000
  */}}
  #@todo: In a rolling update this is going to break some containers (new db -> old code).
  #@todo: Rollback is also not possible (db is gonna stay the same).
  env:
  - name: DRUPAL_DATABASE_HOST
    valueFrom:
      configMapKeyRef:
        name: {{ .Values.global.project }}-{{ .Values.global.environment }}-app
        key: database.host
  - name: DRUPAL_DATABASE_PORT
    valueFrom:
      configMapKeyRef:
        name: {{ .Values.global.project }}-{{ .Values.global.environment }}-app
        key: database.port
  - name: DRUPAL_DATABASE_USERNAME
    valueFrom:
      secretKeyRef:
        name: {{ .Values.global.project }}-{{ .Values.global.environment }}-database
        key: mariadb-username
  - name: DRUPAL_DATABASE_PASSWORD
    valueFrom:
      secretKeyRef:
        name: {{ .Values.global.project }}-{{ .Values.global.environment }}-database
        key: mariadb-password
  - name: DRUPAL_DATABASE_NAME
    valueFrom:
      secretKeyRef:
        name: {{ .Values.global.project }}-{{ .Values.global.environment }}-database
        key: mariadb-db-name
  - name: DRUPAL_HASH_SALT
    valueFrom:
      secretKeyRef:
        name: {{ .Values.global.project }}-{{ .Values.global.environment }}-app-settings
        key: drupal-hash-salt
  - name: DRUSH_BASE_URI
    valueFrom:
      configMapKeyRef:
        name: {{ .Values.global.project }}-{{ .Values.global.environment }}-app
        key: drush-site-uri
  - name: DRUPAL_BASE_URI
    valueFrom:
      configMapKeyRef:
        name: {{ .Values.global.project }}-{{ .Values.global.environment }}-app
        key: drupal-base-uri
  {{- if eq .Values.solr.enable true }}
  - name: SOLR_HOST
    valueFrom:
      configMapKeyRef:
        name: {{ include "app.solrConfName" . | trim }}
        key: host
  - name: SOLR_CORE
    valueFrom:
      configMapKeyRef:
        name: {{ include "app.solrConfName" . | trim }}
        key: core
  {{- if eq .Values.solr.authenticate true }}
  - name: SOLR_USERNAME
    valueFrom:
      secretKeyRef:
        name: {{ include "app.solrSecretName" . | trim }}
        key: username
  - name: SOLR_PASSWORD
    valueFrom:
      secretKeyRef:
        name: {{ include "app.solrSecretName" . | trim }}
        key: password
  {{- end }}
  {{- end }}
  {{- if eq .Values.redis.enable true }}
  - name: REDIS_HOST
    valueFrom:
      configMapKeyRef:
        name: {{ include "app.redisConfName" . | trim }}
        key: host
  {{- if eq .Values.redis.authenticate true }}
  - name: REDIS_PASSWORD
    valueFrom:
      secretKeyRef:
        name: {{ include "app.redisSecretName" . | trim }}
        key: password
  {{- end }}
  {{- end }}
  {{- if not (.Values.drupalExtraEnvVars | empty) -}}
  {{ toYaml .Values.drupalExtraEnvVars | nindent 2 }}
  {{- end }}
  ports:
  - name: fastcgi
    containerPort: 9000
    protocol: TCP
  volumeMounts:
  {{- include "common.mounts" . | indent 2 -}}
  {{- include "drupal.mounts" . | indent 2 -}}
{{ end }}

{{ define "drupal.app.resources" }}
requests:
  cpu: "10m"
  memory: "32Mi"
limits:
  cpu: "800m"
  memory: "512Mi"
{{ end }}

{{ define "drupal.job.resources" }}
requests:
  cpu: "10m"
  memory: "32Mi"
limits:
  cpu: "1000m"
  memory: "2048Mi"
{{ end }}

{{ define "drupal.cron.resources" }}
{{- include "drupal.job.resources" . }}
{{ end }}

{{ define "drupal.backupJob.resources" }}
{{- include "drupal.job.resources" . }}
{{ end }}

{{ define "drupal.deployJob.resources" }}
{{- include "drupal.job.resources" . }}
{{ end }}

{{ define "drupal.backupRestoreJob.resources" }}
{{- include "drupal.job.resources" . }}
{{ end }}
