{{/* Generic templates. */}}
{{/* Drupal data volumes */}}
{{ define "drupal.data.volumes" }}
- name: drupal-data
  persistentVolumeClaim:
    claimName: {{ .Values.global.project }}-{{ .Values.global.environment }}-app-pvc
{{ end }}

{{/* Drupal data volume mounts */}}
{{ define "drupal.data.mounts" }}
- name: drupal-data
  mountPath: /var/www/html/private_files
  subPath: private_files
- name: drupal-data
  mountPath: /var/www/html/web/sites/default/files
  subPath: files
{{ end }}

{{/* Drupal backup volumes */}}
{{ define "drupal.backup.volumes" }}
- name: drupal-database-backups
  persistentVolumeClaim:
    claimName: {{ .Values.global.project }}-{{ .Values.global.environment }}-app-backups-pvc
{{ end }}

{{/* Drupal backup volume mounts */}}
{{ define "drupal.backup.mounts" }}
- name: drupal-database-backups
  mountPath: /backups
  subPath: backups
{{ end }}

{{- define "drupal.appUri" -}}
http{{- if .Values.ingress.tlsSecret -}}s{{- end -}}://{{ .Values.ingress.host }}
{{- end -}}

{{- define "deployment.commonSelectors" }}
environment: {{ .Values.global.environment }}
app.kubernetes.io/instance: {{ .Release.Name | quote }}
app.kubernetes.io/part-of: {{ .Values.global.project }}
app.kubernetes.io/component: app
{{- end }}

{{- define "deployment.selectorLabels" }}
{{- include "deployment.commonSelectors" . }}
deployment: {{ .Values.global.project }}-{{ .Values.global.environment }}-app
{{- end }}

{{- define "deployment.frontendSelectorLabels" }}
{{- include "deployment.commonSelectors" . }}
deployment: {{ .Values.global.project }}-{{ .Values.global.environment }}-frontend-app
{{- end }}

{{- define "common.labels" }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
app.kubernetes.io/version: {{ .Chart.AppVersion }}
app.kubernetes.io/managed-by: {{ .Release.Service | quote }}
environment: {{ .Values.global.environment }}
app.kubernetes.io/instance: {{ .Release.Name | quote }}
app.kubernetes.io/part-of: {{ .Values.global.project }}
{{- end }}

{{ define "common.mounts" }}
{{- include "drupal.data.mounts" . -}}
{{- include "drupal.robots.mounts" . -}}
{{ end }}

{{ define "common.volumes" }}
{{- include "drupal.data.volumes" . -}}
{{- include "drupal.robots.volumes" . -}}
{{ end }}

{{ define "drupal.mounts" }}
{{- include "drupal.settings.mounts" . -}}
{{- include "drupal.backup.mounts" . -}}
{{- /* @todo: Add a ramdisk volume for /tmp/drupal-storage */}}
{{ end }}

{{ define "drupal.volumes" }}
{{- include "drupal.settings.volumes" . -}}
{{- include "drupal.backup.volumes" . -}}
{{ end }}

{{ define "nginx.mounts" }}
{{- /* @todo: Move common.mounts here and mount them as read-only */}}
{{- /* In your pod template, make sure that you set spec.volumes.persistentVolumeClaim.readOnly to true. This ensures the volume is attached in readonly mode. */}}
{{ end }}

{{ define "nginx.volumes" }}
{{ end }}

{{- define "app.solrConfName" -}}
{{ if .Values.solr.existingConfig | empty -}}
"{{ .Values.global.project }}-{{ .Values.global.environment }}-app-solr"
{{ else }}
{{ .Values.solr.existingConfig | quote }}
{{ end }}
{{- end -}}

{{- define "app.solrSecretName" -}}
{{ if .Values.solr.existingSecret | empty -}}
"{{ .Values.global.project }}-{{ .Values.global.environment }}-app-solr"
{{ else }}
{{ .Values.solr.existingSecret | quote }}
{{ end }}
{{- end -}}

{{- define "app.redisConfName" -}}
{{ if .Values.redis.existingConfig | empty -}}
"{{ .Values.global.project }}-{{ .Values.global.environment }}-app-redis"
{{ else }}
{{ .Values.redis.existingConfig | quote }}
{{ end }}
{{- end -}}

{{- define "app.redisSecretName" -}}
{{ if .Values.redis.existingSecret | empty -}}
"{{ .Values.global.project }}-{{ .Values.global.environment }}-app-redis"
{{ else }}
{{ .Values.redis.existingSecret | quote }}
{{ end }}
{{- end -}}

{{- define "app.trustedHostsConfigName" -}}
{{ if .Values.trustedHosts.existingConfig | empty -}}
"{{ .Values.global.project }}-{{ .Values.global.environment }}-app-trusted-hosts"
{{ else }}
{{ .Values.trustedHosts.existingConfig | quote }}
{{ end }}
{{- end -}}

{{/* Stuff for robots.txt overrides. */}}
{{- define "app.robotsConfName" -}}
{{ if .Values.robotsOverride.existingConfig | empty -}}
"{{ .Values.global.project }}-{{ .Values.global.environment }}-app-robotstxt"
{{ else }}
{{ .Values.robotsOverride.existingConfig | quote }}
{{ end }}
{{- end -}}

{{ define "drupal.robots.volumes" }}
{{- if eq .Values.robotsOverride.enable true -}}
- name: robots-file
  configMap:
    name: {{ include "app.robotsConfName" . | trim }}
    items:
      - key: robots.txt
        path: robots.txt
{{- end -}}
{{ end }}

{{ define "drupal.robots.mounts" }}
{{- if eq .Values.robotsOverride.enable true -}}
- name: robots-file
  mountPath: /var/www/html/web/robots.txt
  subPath: robots.txt
  readOnly: true
{{- end -}}
{{ end }}

{{- define "redis.cachePrefix" -}}
{{ .Values.global.project | replace "-" "_" }}_{{ .Values.global.environment | replace "-" "_" }}
{{- end -}}

{{- define "ingress.rule" -}}
{{- /* Note, requires special context, won't work with '.'. */ -}}
- host: {{ .host }}
  http:
    paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: {{ .global.project }}-{{ .global.environment }}-app-service
            port:
              name: http
      {{- if not (.ingress.additionalPaths | empty) -}}
      {{ toYaml .ingress.additionalPaths | nindent 6 }}
      {{- end -}}
{{- end -}}

{{- define "frontend-ingress.rule" -}}
{{- /* Note, requires special context, won't work with '.'. */ -}}
- host: {{ .host }}
  http:
    paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: {{ .global.project }}-{{ .global.environment }}-frontend-app-service
            port:
              name: http
      {{- if not (.dedicatedFrontend.ingress.additionalPaths | empty) -}}
      {{ toYaml .dedicatedFrontend.ingress.additionalPaths | nindent 6 }}
      {{- end -}}
{{- end -}}
