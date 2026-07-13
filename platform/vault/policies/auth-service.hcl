path "kv/data/auth-service/*" {
  capabilities = ["read"]
}

path "kv/metadata/auth-service/*" {
  capabilities = ["list", "read"]
}
