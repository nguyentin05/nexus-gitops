path "kv/data/api-gateway/*" {
  capabilities = ["read"]
}

path "kv/metadata/api-gateway/*" {
  capabilities = ["list", "read"]
}
