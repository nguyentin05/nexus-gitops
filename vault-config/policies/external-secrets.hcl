path "kv/data/auth-service/*" {
  capabilities = ["read"]
}

path "kv/metadata/auth-service/*" {
  capabilities = ["list", "read"]
}

path "kv/data/profile-service/*" {
  capabilities = ["read"]
}

path "kv/metadata/profile-service/*" {
  capabilities = ["list", "read"]
}

path "database/creds/auth-service" {
  capabilities = ["read"]
}

path "database/creds/profile-service" {
  capabilities = ["read"]
}
