# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_1kg_org_session',
  :secret      => '1a72951ead92ea6e739efa07a4fcb2ca5a752f2e1143609d11a2d217eaa8cfa827d5f1c97af1470797db9fb417d0c6af0fe2b486f5c2760a5e258a8793c89294'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
ActionController::Dispatcher.middleware.use FlashSessionCookieMiddleware, ActionController::Base.session_options[:key]