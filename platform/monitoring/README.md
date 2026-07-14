# Monitoring

This directory contains development values for `kube-prometheus-stack` and custom Grafana dashboards.

The stack installs Prometheus, Grafana, Alertmanager, kube-state-metrics, node-exporter, and Prometheus Operator CRDs through ArgoCD. Loki, Promtail, and OpenTelemetry Collector are managed as separate ArgoCD applications.

## Access

Grafana is intentionally internal-only in dev:

```bash
kubectl -n monitoring port-forward svc/monitoring-grafana 3000:80
```

Default dev login:

- Username: `admin`
- Password: `prom-operator`

## Notes

Persistent volumes are disabled for the dev environment to keep the cluster cheap and easy to destroy. Prometheus retention is short by design. Grafana dashboard ConfigMaps are loaded by the Grafana sidecar using the `grafana_dashboard=1` label.
