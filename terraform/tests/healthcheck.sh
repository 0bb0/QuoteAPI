#!/usr/bin/env bash
set -euo pipefail

# --- Required variables ---
REQUIRED_VARS=(API_URL DB_HOST DB_USER DB_PASS DB_NAME)

for var in "${REQUIRED_VARS[@]}"; do
  if [ -z "${!var:-}" ]; then
    echo "Error: Missing required variable: $var"
    echo "Terraform target usage: make healthcheck ENV=<env>"
    exit 1
  fi
done


# --- HTTP check ---
check_http() {
  echo "Checking HTTP endpoint: $API_URL"
  if curl -fsS -o /dev/null "$API_URL"; then
    echo "Info: API $API_URL - HTTP 200 OK"
  else
    echo "Error: $API_URL - Healthcheck failed"
    exit 1
  fi
}

# --- PostgreSQL check ---
check_db() {
  echo "Checking PostgreSQL at $DB_HOST/$DB_NAME as $DB_USER"
  if PGPASSWORD="$DB_PASS" psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -c "SELECT 1;" >/dev/null 2>&1; then
    echo "Info: DB $DB_USER@$DB_HOST/$DB_NAME - OK"
  else
    echo "Error: DB $DB_USER@$DB_HOST/$DB_NAME - Healthcheck failed"
    exit 1
  fi
}

# --- Run checks ---
check_http
check_db

