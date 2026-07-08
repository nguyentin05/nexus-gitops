# External Secrets Operator

ESO reads Vault KV v2 and materializes app secrets as Kubernetes Secrets in the `apps` namespace.

Order:

1. Vault is deployed and initialized.
2. `vault-config/scripts/bootstrap.sh` creates the `external-secrets` Vault role and policy.
3. ESO is deployed.
4. `SecretStore` and `ExternalSecret` resources sync Vault paths into Kubernetes Secrets.

Current synced targets:

- `kv/api-gateway/config` -> `apps/api-gateway-secrets`
- `kv/auth-service/config` -> `apps/auth-service-secrets`
