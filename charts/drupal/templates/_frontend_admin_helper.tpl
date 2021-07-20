{{ define "frontend-admin.image-name" }}
{{ .name }}:{{ .tag }}
{{ end }}

{{- define "deployment.frontendAdminRedirectSelectors" }}
{{- include "deployment.commonSelectors" . }}
deployment: {{ .Values.global.project }}-{{ .Values.global.environment }}-frontend-admin-redirect-app
{{- end }}

{{- define "deployment.frontendAdminBlockerSelectors" }}
{{- include "deployment.commonSelectors" . }}
deployment: {{ .Values.global.project }}-{{ .Values.global.environment }}-frontend-admin-block-app
{{- end }}

{{/* @note, requires special variables in the context */}}
{{/*
  _deploymentType: type of the deployment, redirect or block
  _deploymentSelectorName: name of the selector template, e.g. deployment.frontendAdminRedirectSelectors
  _image
*/}}
{{- define "frontend-admin.deployment" }}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Values.global.project }}-{{ .Values.global.environment }}-frontend-admin-{{ ._deploymentType }}-app
  labels:
    {{- include "common.labels" . | indent 4 }}
    app.kubernetes.io/component: app
    deployment: {{ .Values.global.project }}-{{ .Values.global.environment }}-frontend-admin-{{ ._deploymentType }}-app
spec:
  selector:
    matchLabels:
    {{- include ._deploymentSelectorName . | indent 6 }}
  template:
    metadata:
      labels:
      {{- include ._deploymentSelectorName . | indent 8 }}
    spec:
      terminationGracePeriodSeconds: {{ .Values.gracefulUpdate.terminationGracePeriodSeconds | default "15" }}
      securityContext:
        fsGroup: 1000
{{/* @todo: Try pulling the default nginx image, allow customizing it later.. */}}
{{/*      imagePullSecrets:*/}}
{{/*        - name: {{ .Values.imagePullSecret }}*/}}
      volumes:
        - name: common-config
          configMap:
            name: {{ .Values.global.project }}-{{ .Values.global.environment }}-frontend-admin-common-config
            items:
              - key: nginx.conf
                path: nginx.conf
        - name: vhost-config
          configMap:
            name: {{ .Values.global.project }}-{{ .Values.global.environment }}-frontend-admin-{{ ._deploymentType }}-config
            items:
              - key: default.conf
                path: default.conf
      containers:
        - name: nginx
          imagePullPolicy: {{ .Values.imagePullPolicy }}
          image: {{ ._image }}
          env:
            - name: NGINX_TARGET_PORT
              value: {{ .Values.nginxTargetPort | default 8080 | quote }}
            - name: NGINX_HEALTH_PORT
              value: {{ .Values.nginxHealthPort | default 9002 | quote }}
          ports:
            - name: http
              containerPort: {{ .Values.nginxTargetPort | default 8080 }}
            - name: nginx-health
              containerPort: {{ .Values.nginxHealthPort | default 9002 }}
          volumeMounts:
            - name: vhost-config
              mountPath: /etc/nginx/conf.d/default.conf
              subPath: default.conf
              readOnly: true
            - name: common-config
              mountPath: /etc/nginx/nginx.conf
              subPath: nginx.conf
              readOnly: true
          lifecycle:
            # @todo: Graceful shutdown needed:
            # command: ["/bin/sh", "-c", "sleep 5; /usr/local/openresty/nginx/sbin/nginx -c /etc/nginx/nginx.conf -s quit; while pgrep -x nginx; do sleep 1; done"]
            preStop:
            {{- include "common.deployment.lifecyle.preStop" . | indent 14 }}
          resources:
            requests:
              cpu: {{ .Values.dedicatedFrontend.resources.nginxCpuRequest | default "10m" | quote }}
              memory: {{ .Values.dedicatedFrontend.resources.nginxMemoryRequest | default "32Mi" | quote }}
            limits:
              cpu: {{ .Values.dedicatedFrontend.resources.nginxCpuLimit | default "100m" | quote }}
              memory: {{ .Values.dedicatedFrontend.resources.nginxMemoryLimit | default "128Mi" | quote }}
          livenessProbe:
            exec:
              command:
                - "/bin/sh"
                - "-c"
                - "/usr/bin/curl --silent --show-error --fail --header 'Host: internal.health' http://127.0.0.1:${NGINX_HEALTH_PORT}/status"
            failureThreshold: 3
            initialDelaySeconds: 5
            periodSeconds: 10
            timeoutSeconds: 5
          readinessProbe:
            exec:
              command:
               - "/bin/sh"
               - "-c"
               - "/usr/bin/curl --silent --show-error --fail --header 'Host: internal.health' http://127.0.0.1:${NGINX_HEALTH_PORT}/status"
            failureThreshold: 3
            initialDelaySeconds: 5
            periodSeconds: 10
            timeoutSeconds: 5
{{- end }}

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

{{- define "frontend-ingress.block-path" -}}
{{- /* Note, requires special context, won't work with '.'. */ -}}
- path: {{ .path }}
  pathType: Prefix
  backend:
    service:
      name: {{ .global.project }}-{{ .global.environment }}-frontend-admin-block-app-service
      port:
        name: http
{{- end -}}

{{- define "frontend-ingress.redirect-path" -}}
{{- /* Note, requires special context, won't work with '.'. */ -}}
- path: {{ .path }}
  pathType: Prefix
  backend:
    service:
      name: {{ .global.project }}-{{ .global.environment }}-frontend-admin-redirect-app-service
      port:
        name: http
{{- end -}}
