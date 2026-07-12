#!/usr/bin/env sh
set -eu

: "${VAULT_ADDR:=http://vault.vault.svc:8200}"
: "${NEXUS_DB_NAME:=nexus}"
: "${DATABASE_ENDPOINT:?DATABASE_ENDPOINT is required}"
: "${USER_EVENTS_QUEUE_URL:?USER_EVENTS_QUEUE_URL is required}"
: "${JWT_SECRET:?JWT_SECRET is required}"

vault kv patch kv/auth-service/config \
  DATABASE_ENDPOINT="$DATABASE_ENDPOINT" \
  DATABASE_NAME="$NEXUS_DB_NAME" \
  USER_EVENTS_QUEUE_URL="$USER_EVENTS_QUEUE_URL" \
  JWT_SECRET="$JWT_SECRET"

vault kv patch kv/profile-service/config \
  DATABASE_ENDPOINT="$DATABASE_ENDPOINT" \
  DATABASE_NAME="$NEXUS_DB_NAME" \
  USER_EVENTS_QUEUE_URL="$USER_EVENTS_QUEUE_URL" \
  JWT_SECRET="$JWT_SECRET"

if [ -n "${CLOUDINARY_CLOUD_NAME:-}" ] || [ -n "${CLOUDINARY_API_KEY:-}" ] || [ -n "${CLOUDINARY_API_SECRET:-}" ]; then
  : "${CLOUDINARY_CLOUD_NAME:?CLOUDINARY_CLOUD_NAME is required when Cloudinary is configured}"
  : "${CLOUDINARY_API_KEY:?CLOUDINARY_API_KEY is required when Cloudinary is configured}"
  : "${CLOUDINARY_API_SECRET:?CLOUDINARY_API_SECRET is required when Cloudinary is configured}"

  vault kv patch kv/profile-service/config \
    CLOUDINARY_CLOUD_NAME="$CLOUDINARY_CLOUD_NAME" \
    CLOUDINARY_API_KEY="$CLOUDINARY_API_KEY" \
    CLOUDINARY_API_SECRET="$CLOUDINARY_API_SECRET" \
    CLOUDINARY_FOLDER="${CLOUDINARY_FOLDER:-nexus/avatars}"
fi
