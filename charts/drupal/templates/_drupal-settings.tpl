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
{{ end }}

{{/* Drupal settings volume mounts */}}
{{ define "drupal.settings.mounts" }}
- name: trusted-hosts-settings
  mountPath: /var/www/html/settings/_settings.trusted-hosts.php
  subPath: settings.trusted-hosts.php
  readOnly: true
- name: email-settings
  mountPath: /var/www/html/settings/settings.email.php
  subPath: settings.email.php
  readOnly: true
{{ end }}
