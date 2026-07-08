# ArgoCD Bootstrap

ArgoCD is installed manually once. After that, `nexus-gitops` syncs platform and app resources from this repository.

## Install

Run these commands after the EKS cluster is live and `kubectl get nodes` works:

```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
cp bootstrap/argocd-github-app-values.yaml.example bootstrap/argocd-github-app-values.yaml
# Edit bootstrap/argocd-github-app-values.yaml with the GitHub App ID,
# installation ID, and private key PEM content.
helm upgrade --install argocd argo/argo-cd \
  --version 9.5.21 \
  --namespace argocd \
  --create-namespace \
  -f bootstrap/argocd-values.yaml \
  -f bootstrap/argocd-github-app-values.yaml
kubectl -n argocd rollout status deployment/argocd-server
kubectl apply -f bootstrap/gitops-application.yaml
```

## Validate

```bash
kubectl get pods -n argocd
kubectl get applications -n argocd
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Open `https://localhost:8080`.

Initial admin password:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath='{.data.password}' | base64 -d
```

## Sync Waves

- `-1`: namespaces
- `1`: Vault
- `2`: External Secrets Operator
- `3`: ExternalSecret and SecretStore config
- `4`: Envoy Gateway
- `5`: Envoy Gateway route config

## Private GitHub Repository Access

Use a GitHub App for ArgoCD access to the private `nexus-gitops` repo.

GitHub App settings:

- Repository permissions: `Contents: Read-only`, `Metadata: Read-only`
- Install the app only on `nguyentin05/nexus-gitops`
- Generate a private key and save the `.pem` file outside this repository

The private key is loaded during the ArgoCD Helm install through
`bootstrap/argocd-github-app-values.yaml`. This local file is ignored by Git.
Keep `githubAppID` and `githubAppInstallationID` as quoted strings with `!!str` so YAML does not convert them to scientific notation.

If ArgoCD is already installed, run the same Helm command again with both values
files to upgrade the release and create the credential template:

```bash
helm upgrade --install argocd argo/argo-cd \
  --version 9.5.21 \
  --namespace argocd \
  --create-namespace \
  -f bootstrap/argocd-values.yaml \
  -f bootstrap/argocd-github-app-values.yaml
```

Then check sync:

```bash
kubectl -n argocd annotate application nexus-gitops \
  argocd.argoproj.io/refresh=hard --overwrite
kubectl get applications -n argocd -o wide
kubectl describe application nexus-gitops -n argocd
```
