#!/usr/bin/env sh

# Exit immediately if a command exits with a non-zero status.
set -e

echo "--- Running database migrations ---"
bundle exec rails db:migrate

echo "--- Starting Rails server ---"
# This command executes the CMD from the Dockerfile (i.e., starts the rails server).
exec "$@"
