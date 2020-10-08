{{/*
Drupal settings files.
This was moved to a separate file as this is the only mount-related code that can differ between projects.
*/}}

{{/* Drupal settings volumes */}}
{{ define "drupal.settings.volumes" }}
{{- if eq .Values.trustedHosts.enable true }}
- name: trusted-hosts-settings
  configMap:
    name: {{ include "app.trustedHostsConfigName" . | trim }}
    items:
      - key: settings.trusted-hosts.php
        path: settings.trusted-hosts.php
{{- end }}
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
{{- if eq .Values.trustedHosts.enable true }}
- name: trusted-hosts-settings
  mountPath: /var/www/html/settings/settings.trusted-hosts.php
  subPath: settings.trusted-hosts.php
  readOnly: true
{{- end }}
{{- if eq .Values.solr.enable true }}
- name: solr-settings
  mountPath: {{ .Values.drupalSettingsDir | trim }}/settings.solr.php
  subPath: settings.solr.php
  readOnly: true
{{- end }}
{{- if eq .Values.redis.enable true }}
- name: redis-settings
  mountPath: {{ .Values.drupalSettingsDir | trim }}/settings.redis.php
  subPath: settings.redis.php
  readOnly: true
{{- end }}
{{- if not (.Values.drupalExtraSettings.mounts | empty) -}}
{{ toYaml .Values.drupalExtraSettings.mounts | nindent 0 }}
{{- end -}}
{{ end }}
