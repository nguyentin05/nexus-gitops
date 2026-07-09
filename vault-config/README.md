# Vault Config

Run after Vault is initialized, unsealed, and reachable with a root/admin token.

```bash
export VAULT_ADDR="http://127.0.0.1:8200"
export VAULT_TOKEN="<admin-token>"
./scripts/bootstrap.sh
```

The script enables KV v2 at `kv/`, creates the placeholder secret path for `auth-service`, configures Vault Kubernetes auth, and binds the `apps/external-secrets` ServiceAccount to the `external-secrets` Vault policy.

App pods no longer authenticate to Vault directly. External Secrets Operator reads Vault and creates Kubernetes Secrets for the apps.
