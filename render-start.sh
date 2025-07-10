#!/usr/bin/env sh

# This script runs the database migration and then starts the Rails server.

# Exit immediately if a command exits with a non-zero status.
set -e

# Run the database migration
bundle exec rails db:migrate

# Then, exec the container's main process (what's set as CMD in the Dockerfile).
exec "$@"
