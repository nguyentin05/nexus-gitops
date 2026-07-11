# Monitoring

This directory contains development values for `kube-prometheus-stack`.

The stack installs Prometheus, Grafana, Alertmanager, kube-state-metrics, node-exporter, and Prometheus Operator CRDs through ArgoCD.

## Access

Grafana is intentionally internal-only in dev:

```bash
kubectl -n monitoring port-forward svc/monitoring-grafana 3000:80
```

Default dev login:

- Username: `admin`
- Password: `prom-operator`

## Notes

Persistent volumes are disabled for the dev environment to keep the cluster cheap and easy to destroy. Prometheus retention is short by design. Loki, Promtail, OpenTelemetry Collector, and app-specific ServiceMonitors should be added in separate GitOps changes.
