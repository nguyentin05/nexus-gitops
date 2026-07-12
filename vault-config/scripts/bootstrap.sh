#!/usr/bin/env sh
set -eu

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
POLICY_DIR="${VAULT_POLICY_DIR:-$(cd "${SCRIPT_DIR}/../policies" && pwd)}"
KUBERNETES_CA_CERT="${KUBERNETES_CA_CERT:-/var/run/secrets/kubernetes.io/serviceaccount/ca.crt}"

: "${VAULT_ADDR:=http://vault.vault.svc:8200}"
: "${KUBERNETES_HOST:=https://kubernetes.default.svc}"
: "${NEXUS_DB_NAME:=nexus}"

vault secrets enable -path=kv kv-v2 2>/dev/null || true

vault kv get kv/auth-service/config >/dev/null 2>&1 || vault kv put kv/auth-service/config placeholder=true DATABASE_NAME="$NEXUS_DB_NAME"
vault kv get kv/profile-service/config >/dev/null 2>&1 || vault kv put kv/profile-service/config placeholder=true DATABASE_NAME="$NEXUS_DB_NAME"

vault auth enable kubernetes 2>/dev/null || true

if [ -f "$KUBERNETES_CA_CERT" ]; then
  vault write auth/kubernetes/config \
    kubernetes_host="$KUBERNETES_HOST" \
    kubernetes_ca_cert=@"$KUBERNETES_CA_CERT"
else
  vault write auth/kubernetes/config kubernetes_host="$KUBERNETES_HOST"
fi

vault policy write external-secrets "${POLICY_DIR}/external-secrets.hcl"

vault write auth/kubernetes/role/external-secrets \
  bound_service_account_names=external-secrets \
  bound_service_account_namespaces=apps \
  policies=external-secrets \
  ttl=1h

if [ -n "${NEXUS_DB_CONNECTION_URL:-}" ]; then
  : "${NEXUS_DB_ADMIN_USERNAME:?NEXUS_DB_ADMIN_USERNAME is required when NEXUS_DB_CONNECTION_URL is set}"
  : "${NEXUS_DB_ADMIN_PASSWORD:?NEXUS_DB_ADMIN_PASSWORD is required when NEXUS_DB_CONNECTION_URL is set}"

  vault secrets enable database 2>/dev/null || true

  vault write database/config/nexus-postgres \
    plugin_name=postgresql-database-plugin \
    allowed_roles="auth-service,profile-service" \
    connection_url="$NEXUS_DB_CONNECTION_URL" \
    username="$NEXUS_DB_ADMIN_USERNAME" \
    password="$NEXUS_DB_ADMIN_PASSWORD"

  for role in auth-service profile-service; do
    vault write "database/roles/${role}" \
      db_name=nexus-postgres \
      default_ttl="${NEXUS_DB_DEFAULT_TTL:-1h}" \
      max_ttl="${NEXUS_DB_MAX_TTL:-24h}" \
      creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; GRANT CONNECT ON DATABASE ${NEXUS_DB_NAME} TO \"{{name}}\"; GRANT USAGE, CREATE ON SCHEMA public TO \"{{name}}\"; GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO \"{{name}}\"; GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO \"{{name}}\";" \
      revocation_statements="REASSIGN OWNED BY \"{{name}}\" TO CURRENT_USER; DROP OWNED BY \"{{name}}\"; DROP ROLE IF EXISTS \"{{name}}\";"
  done
fi
