# OpenTelemetry Collector

This installs the OpenTelemetry Collector as a DaemonSet in the `monitoring`
namespace.

Current role:

- receive OTLP traffic on `4317` and `4318`
- expose collector self metrics on `8888`
- expose OTLP metrics to Prometheus on `8889`
- keep traces and logs on the debug exporter until a trace backend is added

Promtail and Loki remain the Kubernetes log pipeline. Prometheus remains the
metrics store. The collector is the app telemetry entry point for later service
instrumentation.
