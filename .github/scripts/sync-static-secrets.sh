#!/usr/bin/env sh
set -eu

: "${VAULT_ADDR:=http://vault.vault.svc:8200}"
: "${NEXUS_DB_NAME:=nexus}"
: "${DATABASE_ENDPOINT:?DATABASE_ENDPOINT is required}"
: "${USER_EVENTS_QUEUE_URL:?USER_EVENTS_QUEUE_URL is required}"
: "${JWT_SECRET:?JWT_SECRET is required}"
: "${DISCORD_WEBHOOK_URL:?DISCORD_WEBHOOK_URL is required}"
: "${GEMINI_API_KEY:?GEMINI_API_KEY is required}"

vault kv put kv/monitoring/alertmanager \
  DISCORD_WEBHOOK_URL="$DISCORD_WEBHOOK_URL" \
  GEMINI_API_KEY="$GEMINI_API_KEY"

vault kv put kv/auth-service/config \
  DATABASE_ENDPOINT="$DATABASE_ENDPOINT" \
  DATABASE_NAME="$NEXUS_DB_NAME" \
  USER_EVENTS_QUEUE_URL="$USER_EVENTS_QUEUE_URL" \
  JWT_SECRET="$JWT_SECRET"

if [ -n "${CLOUDINARY_CLOUD_NAME:-}" ] || [ -n "${CLOUDINARY_API_KEY:-}" ] || [ -n "${CLOUDINARY_API_SECRET:-}" ]; then
  : "${CLOUDINARY_CLOUD_NAME:?CLOUDINARY_CLOUD_NAME is required when Cloudinary is configured}"
  : "${CLOUDINARY_API_KEY:?CLOUDINARY_API_KEY is required when Cloudinary is configured}"
  : "${CLOUDINARY_API_SECRET:?CLOUDINARY_API_SECRET is required when Cloudinary is configured}"

  vault kv put kv/profile-service/config \
    DATABASE_ENDPOINT="$DATABASE_ENDPOINT" \
    DATABASE_NAME="$NEXUS_DB_NAME" \
    USER_EVENTS_QUEUE_URL="$USER_EVENTS_QUEUE_URL" \
    JWT_SECRET="$JWT_SECRET" \
    CLOUDINARY_CLOUD_NAME="$CLOUDINARY_CLOUD_NAME" \
    CLOUDINARY_API_KEY="$CLOUDINARY_API_KEY" \
    CLOUDINARY_API_SECRET="$CLOUDINARY_API_SECRET" \
    CLOUDINARY_FOLDER="${CLOUDINARY_FOLDER:-nexus/avatars}"
else
  vault kv put kv/profile-service/config \
    DATABASE_ENDPOINT="$DATABASE_ENDPOINT" \
    DATABASE_NAME="$NEXUS_DB_NAME" \
    USER_EVENTS_QUEUE_URL="$USER_EVENTS_QUEUE_URL" \
    JWT_SECRET="$JWT_SECRET"
fi
