path "kv/data/profile-service/*" {
  capabilities = ["read"]
}

path "kv/metadata/profile-service/*" {
  capabilities = ["list", "read"]
}
