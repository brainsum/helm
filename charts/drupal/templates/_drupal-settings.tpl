{{/*
Drupal settings files.
This was moved to a separate file as this is the only mount-related code that can differ between projects.
*/}}

{{/* Drupal settings volumes */}}
{{ define "drupal.settings.volumes" }}
- name: trusted-hosts-settings
  secret:
    secretName: {{ .Values.global.project }}-{{ .Values.global.environment }}-app-settings
    items:
      - key: settings.trusted-hosts.php
        path: settings.trusted-hosts.php
- name: email-settings
  secret:
    secretName: {{ .Values.global.project }}-{{ .Values.global.environment }}-app-settings
    items:
      - key: settings.email.php
        path: settings.email.php
{{- if eq .Values.solr.enable true}}
- name: solr-settings
  configMap:
    name: {{ include "app.solrConfName" . | trim }}
    items:
      - key: settings.solr.php
        path: settings.solr.php
{{- end }}
{{- if eq .Values.redis.enable true }}
- name: redis-settings
  configMap:
    name: {{ include "app.redisConfName" . | trim }}
    items:
      - key: settings.redis.php
        path: settings.redis.php
{{- end }}
{{- if not (.Values.drupalExtraSettings.volumes | empty) -}}
{{ toYaml .Values.drupalExtraSettings.volumes | nindent 0 }}
{{- end -}}
{{ end }}

{{/* Drupal settings volume mounts */}}
{{ define "drupal.settings.mounts" }}
- name: trusted-hosts-settings
  mountPath: /var/www/html/settings/settings.trusted-hosts.php
  subPath: settings.trusted-hosts.php
  readOnly: true
- name: email-settings
  mountPath: /var/www/html/settings/settings.email.php
  subPath: settings.email.php
  readOnly: true
{{- if eq .Values.solr.enable true}}
- name: solr-settings
  mountPath: /var/www/html/settings/settings.solr.php
  subPath: settings.solr.php
  readOnly: true
{{- end }}
{{- if eq .Values.redis.enable true }}
- name: redis-settings
  mountPath: /var/www/html/settings/settings.redis.php
  subPath: settings.redis.php
  readOnly: true
{{- end }}
{{- if not (.Values.drupalExtraSettings.mounts | empty) -}}
{{ toYaml .Values.drupalExtraSettings.mounts | nindent 0 }}
{{- end -}}
{{ end }}
