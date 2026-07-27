{{- define "profile-service.podTemplate" -}}
template:
  metadata:
    labels:
      app.kubernetes.io/name: {{ include "profile-service.name" . }}
      app.kubernetes.io/instance: {{ .Release.Name }}
  spec:
    serviceAccountName: {{ include "profile-service.serviceAccountName" . }}
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
        {{- with .Values.env }}
        env:
          {{- toYaml . | nindent 12 }}
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
          secretName: {{ include "profile-service.fullname" . }}-secrets
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
