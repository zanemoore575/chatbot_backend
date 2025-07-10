#!/usr/bin/env sh

# Exit immediately if a command exits with a non-zero status.
set -e

# Set the RAILS_ENV to production to ensure the correct database
# configuration is used for the migration.
export RAILS_ENV=production

echo "--- Running database migrations ---"
bundle exec rails db:migrate

echo "--- Starting Rails server ---"
# This command executes the CMD from the Dockerfile.
exec "$@"
