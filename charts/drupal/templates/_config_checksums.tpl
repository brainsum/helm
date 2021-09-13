{{- define "drupal.configChecksums" -}}
checksum/app-config: {{ include (print $.Template.BasePath "/app-config.yaml") . | sha256sum }}
{{- if eq (.Values.redis.enable | default false) true }}
{{- if .Values.redis.existingConfig | empty }}
checksum/redis-config: {{ include (print $.Template.BasePath "/redis-config.yaml") . | sha256sum }}
{{- end }}
{{- end }}
{{- if eq .Values.trustedHosts.enable true }}
{{- if .Values.trustedHosts.existingConfig | empty }}
checksum/trusted-hosts-config: {{ include (print $.Template.BasePath "/trusted-hosts-config.yaml") . | sha256sum }}
{{- end }}
{{- end }}
{{- if eq .Values.solr.enable true }}
{{- if .Values.solr.existingConfig | empty }}
checksum/solr-config: {{ include (print $.Template.BasePath "/solr-config.yaml") . | sha256sum }}
{{- end }}
{{- end }}
{{- if eq .Values.sessionOverride.enable true }}
{{- if .Values.sessionOverride.existingConfig | empty }}
checksum/session-config: {{ include (print $.Template.BasePath "/session-config.yaml") . | sha256sum }}
{{- end }}
{{- end }}
{{- end }}