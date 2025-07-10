# Load the Rails application.
require_relative "application"

# Manually configure the database URL if it's present.
# This is a robust way to ensure the production database is used.
if ENV["DATABASE_URL"]
  Rails.application.config.database_configuration["production"]["url"] = ENV["DATABASE_URL"]
end

# Initialize the Rails application.
Rails.application.initialize!
