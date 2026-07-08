# Kyverno

Kyverno is deployed by ArgoCD with the official Helm chart.

Current policies run in `Audit` mode and target the `apps` namespace only. This keeps platform bootstrap safe while still giving app workloads clear guardrails.
