#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
POLICY_DIR="${VAULT_POLICY_DIR:-$(cd "${SCRIPT_DIR}/../policies" && pwd)}"
KUBERNETES_CA_CERT="${KUBERNETES_CA_CERT:-/var/run/secrets/kubernetes.io/serviceaccount/ca.crt}"

: "${VAULT_ADDR:=http://vault.vault.svc:8200}"
: "${KUBERNETES_HOST:=https://kubernetes.default.svc}"

vault secrets enable -path=kv kv-v2 2>/dev/null || true

vault kv put kv/api-gateway/config placeholder=true
vault kv put kv/auth-service/config placeholder=true

vault auth enable kubernetes 2>/dev/null || true

if [[ -f "$KUBERNETES_CA_CERT" ]]; then
  vault write auth/kubernetes/config     kubernetes_host="$KUBERNETES_HOST"     kubernetes_ca_cert=@"$KUBERNETES_CA_CERT"
else
  vault write auth/kubernetes/config kubernetes_host="$KUBERNETES_HOST"
fi

vault policy write external-secrets "${POLICY_DIR}/external-secrets.hcl"

vault write auth/kubernetes/role/external-secrets   bound_service_account_names=external-secrets   bound_service_account_namespaces=apps   policies=external-secrets   ttl=1h
