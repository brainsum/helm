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

{{- define "common.labels" }}
environment: {{ .Values.global.environment }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
app.kubernetes.io/managed-by: {{ .Release.Service | quote }}
app.kubernetes.io/instance: {{ .Release.Name | quote }}
app.kubernetes.io/version: {{ .Chart.AppVersion }}
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
{{ end }}

{{ define "drupal.volumes" }}
{{- include "drupal.settings.volumes" . -}}
{{- include "drupal.backup.volumes" . -}}
{{ end }}

{{ define "nginx.mounts" }}
{{ end }}

{{ define "nginx.volumes" }}
{{ end }}

{{/* @todo: Temporary for prod, need to add condition for it. */}}
{{/* Stuff for robots.txt overrides. */}}
{{ define "drupal.robots.volumes" }}
{{- if eq .Values.robotsOverride true -}}
- name: robots-file
  secret:
    secretName: {{ .Values.global.project }}-{{ .Values.global.environment }}-app-settings
    items:
      - key: robots.txt
        path: robots.txt
{{- end -}}
{{ end }}

{{ define "drupal.robots.mounts" }}
{{- if eq .Values.robotsOverride true -}}
- name: robots-file
  mountPath: /var/www/html/web/robots.txt
  subPath: robots.txt
  readOnly: true
{{- end -}}
{{ end }}
