#!/usr/bin/env sh

# Exit immediately if a command exits with a non-zero status.
set -e

# --- DEBUGGING STEP ---
# This block will check if the DATABASE_URL is available.
# If it's not, the script will exit with a clear error message.
echo "--- Verifying environment variables ---"
if [ -z "$DATABASE_URL" ]; then
  echo "ERROR: DATABASE_URL environment variable is not set."
  echo "Please check the Environment tab for your service on Render."
  exit 1
fi
echo "DATABASE_URL is present."
# --- END DEBUGGING STEP ---

# Set the RAILS_ENV to production to ensure the correct database
# configuration is used for the migration.
export RAILS_ENV=production

echo "--- Running database migrations ---"
bundle exec rails db:migrate

echo "--- Starting Rails server ---"
# This command executes the CMD from the Dockerfile (i.e., starts the rails server).
exec "$@"
