# Configure Solid Cache to use the file system
Rails.application.configure do
  # Use file store for Solid Cache
  config.solid_cache.store = :file_store, 'tmp/cache/solid_cache/'
  
  # Disable database connections for Solid Cache
  config.solid_cache.database = nil
  
  # Disable the default cache store that uses the database
  config.solid_cache.default_store = :file_store, 'tmp/cache/'
end

# If you want to completely disable Solid Cache (uncomment if needed)
# Rails.application.config.solid_cache.enabled = false
