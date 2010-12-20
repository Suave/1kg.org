# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.

APP_CONFIG = YAML.load_file("#{Rails.root}/config/config.yml")[Rails.env]

ActionMailer::Base.sendmail_settings = {  
  :address              => "smtp.gmail.com",  
  :port                 => 587,  
  :user_name            => APP_CONFIG['mail_user_name'],  
  :password             => APP_CONFIG['mail_password'],  
  :authentication       => "plain",  
  :enable_starttls_auto => true  
}

config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = true
config.action_controller.perform_caching             = false

# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = false

Paperclip.options[:command_path] = "/usr/bin"