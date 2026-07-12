# Vault Config

Run after Vault is initialized, unsealed, and reachable with a root/admin token.

```bash
export VAULT_ADDR="http://127.0.0.1:8200"
export VAULT_TOKEN="<admin-token>"
./scripts/bootstrap.sh
```

The script is idempotent. It enables KV v2 at `kv/`, configures Kubernetes auth for External Secrets Operator, and writes the `external-secrets` policy.

## Dynamic PostgreSQL credentials

To configure Vault database dynamic secrets, pass the admin connection URL when running the bootstrap script:

```bash
export NEXUS_DB_NAME="nexus"
export NEXUS_DB_ADMIN_USERNAME="<rds-admin-username>"
export NEXUS_DB_ADMIN_PASSWORD="<rds-admin-password>"
export NEXUS_DB_CONNECTION_URL='postgresql://{{username}}:{{password}}@<rds-endpoint>/nexus?sslmode=require'
./scripts/bootstrap.sh
```

`NEXUS_DB_CONNECTION_URL` must contain the literal `{{username}}` and `{{password}}` placeholders. Vault replaces them with `NEXUS_DB_ADMIN_USERNAME` and `NEXUS_DB_ADMIN_PASSWORD` when it connects to PostgreSQL.

After this, ESO reads:

- `database/creds/auth-service`
- `database/creds/profile-service`

and renders `DATABASE_URL` into the app Kubernetes Secrets.

Static values such as `JWT_SECRET`, `USER_EVENTS_QUEUE_URL`, `DATABASE_ENDPOINT`, `DATABASE_NAME`, and Cloudinary keys still live under:

- `kv/auth-service/config`
- `kv/profile-service/config`

## GitHub Actions sync

The `Sync Vault Secrets` workflow runs the same bootstrap inside `vault-0` and then patches static KV values. Configure these repository secrets in `nexus-gitops`:

- `AWS_ROLE_TO_ASSUME`
- `VAULT_TOKEN`
- `NEXUS_DB_ENDPOINT`
- `NEXUS_DB_ADMIN_USERNAME`
- `NEXUS_DB_ADMIN_PASSWORD`
- `USER_EVENTS_QUEUE_URL`
- `JWT_SECRET`
- `CLOUDINARY_CLOUD_NAME`
- `CLOUDINARY_API_KEY`
- `CLOUDINARY_API_SECRET`

Run it from GitHub Actions with `bootstrap_database=true` after Terraform and ArgoCD are up. It refreshes ESO and restarts `auth-service` and `profile-service`.
