# Vault Helm Values

`values-dev.yaml` and `values-prod.yaml` are for the official HashiCorp Vault Helm chart.

Before syncing with ArgoCD, replace:

- `REPLACE_WITH_DEV_VAULT_IRSA_ROLE_ARN`
- `REPLACE_WITH_DEV_VAULT_KMS_KEY_ID`
- `REPLACE_WITH_PROD_VAULT_IRSA_ROLE_ARN`
- `REPLACE_WITH_PROD_VAULT_KMS_KEY_ID`

Use outputs from `nexus-infra` KMS and IAM modules.
