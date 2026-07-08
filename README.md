# nexus-gitops

Desired Kubernetes state for Nexus.

Architecture v2 baseline:

- ArgoCD is bootstrapped manually once, then manages platform and app resources from this repo.
- Vault runs in-cluster and uses AWS KMS auto-unseal.
- External Secrets Operator syncs Vault KV v2 secrets into Kubernetes Secrets for apps.
- Envoy Gateway is the gateway layer; the old `api-gateway` chart is deprecated.
- Kyverno, monitoring, Rollouts, and app manifests will be added as GitOps-managed resources.

## Bootstrap

Install ArgoCD once with the Helm values in `bootstrap/argocd-values.yaml`, then apply `bootstrap/gitops-application.yaml`.

See `bootstrap/README.md` for the exact commands.
