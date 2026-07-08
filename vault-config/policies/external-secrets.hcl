path "kv/data/api-gateway/*" {
  capabilities = ["read"]
}

path "kv/metadata/api-gateway/*" {
  capabilities = ["list", "read"]
}

path "kv/data/auth-service/*" {
  capabilities = ["read"]
}

path "kv/metadata/auth-service/*" {
  capabilities = ["list", "read"]
}
