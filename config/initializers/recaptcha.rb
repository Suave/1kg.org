# -*- encoding : utf-8 -*-
ENV['RECAPTCHA_PUBLIC_KEY']  = YAML.load_file("#{Rails.root}/config/recaptcha.yml")['recaptcha_public_key']
ENV['RECAPTCHA_PRIVATE_KEY'] = YAML.load_file("#{Rails.root}/config/recaptcha.yml")['recaptcha_private_key']


