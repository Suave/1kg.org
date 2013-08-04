APP_CONFIG = YAML.load_file("#{Rails.root}/config/config.yml")[Rails.env]
SPAM_WORDS = APP_CONFIG["spam_words"].split
