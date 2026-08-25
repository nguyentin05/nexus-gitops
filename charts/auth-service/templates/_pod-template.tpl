{{- define "auth-service.podTemplate" -}}
template:
  metadata:
    labels:
      app.kubernetes.io/name: {{ include "auth-service.name" . }}
      app.kubernetes.io/instance: {{ .Release.Name }}
  spec:
    serviceAccountName: {{ include "auth-service.serviceAccountName" . }}
    securityContext:
      runAsNonRoot: true
      runAsUser: 10001
      runAsGroup: 10001
      seccompProfile:
        type: RuntimeDefault
    containers:
      - name: {{ .Chart.Name }}
        image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
        imagePullPolicy: {{ .Values.image.pullPolicy }}
        securityContext:
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: true
          runAsNonRoot: true
          capabilities:
            drop:
              - ALL
        volumeMounts:
          - name: tmp
            mountPath: /tmp
          - name: app-secrets
            mountPath: /var/run/secrets/nexus
            readOnly: true
        ports:
          - name: http
            containerPort: {{ .Values.service.targetPort }}
            protocol: TCP
        env:
          {{- if .Values.telemetry.enabled }}
          - name: OTEL_SERVICE_NAME
            value: {{ .Chart.Name | quote }}
          - name: OTEL_EXPORTER_OTLP_ENDPOINT
            value: {{ .Values.telemetry.endpoint | quote }}
          - name: OTEL_EXPORTER_OTLP_PROTOCOL
            value: http/protobuf
          - name: OTEL_METRICS_EXPORTER
            value: otlp
          - name: OTEL_TRACES_EXPORTER
            value: otlp
          - name: OTEL_LOGS_EXPORTER
            value: none
          - name: OTEL_TRACES_SAMPLER
            value: {{ .Values.telemetry.tracesSampler | quote }}
          - name: OTEL_TRACES_SAMPLER_ARG
            value: {{ .Values.telemetry.tracesSamplerArg | quote }}
          - name: OTEL_METRIC_EXPORT_INTERVAL
            value: {{ .Values.telemetry.metricExportInterval | quote }}
          - name: OTEL_RESOURCE_ATTRIBUTES
            value: {{ printf "deployment.environment.name=%s" .Values.telemetry.environment | quote }}
          {{- end }}
          {{- with .Values.env }}
          {{- toYaml . | nindent 10 }}
          {{- end }}
        {{- with .Values.envFrom }}
        envFrom:
          {{- toYaml . | nindent 12 }}
        {{- end }}
        livenessProbe:
          httpGet:
            path: /health
            port: http
          initialDelaySeconds: 10
          periodSeconds: 20
        readinessProbe:
          httpGet:
            path: /health
            port: http
          initialDelaySeconds: 5
          periodSeconds: 10
        {{- with .Values.resources }}
        resources:
          {{- toYaml . | nindent 12 }}
        {{- end }}
    volumes:
      - name: tmp
        emptyDir: {}
      - name: app-secrets
        secret:
          secretName: {{ include "auth-service.fullname" . }}-secrets
          optional: true
    {{- with .Values.nodeSelector }}
    nodeSelector:
      {{- toYaml . | nindent 8 }}
    {{- end }}
    {{- with .Values.tolerations }}
    tolerations:
      {{- toYaml . | nindent 8 }}
    {{- end }}
    {{- with .Values.affinity }}
    affinity:
      {{- toYaml . | nindent 8 }}
    {{- end }}
{{- end }}
