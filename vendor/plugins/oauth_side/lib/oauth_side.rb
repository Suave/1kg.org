OAUTH_CONFIG = {:sites => {}, :model => nil }

Dir["#{Rails.root}/config/oauth/*.yml"].collect{|f|
  YAML.load_file(f).each_pair{|site,props|
    OAUTH_CONFIG[:sites].update(site.to_sym => {}) unless OAUTH_CONFIG[:sites].has_key? site.to_sym
    if props.class == Hash
      props.each_pair{|k,v|
	    OAUTH_CONFIG[:sites][site.to_sym].update(k.to_sym => v)
	  }
	end
  }
}

module Rails
  class << self
    def oauth
      OAUTH_CONFIG[:sites]
    end
    def oauth_model
      OAUTH_CONFIG[:model]
    end
    def oauth_model= model
      OAUTH_CONFIG[:model]=model
    end
  end
end

Rails.oauth.each_pair{|site,props|
  OauthController.class_eval <<-EOF
    def #{site.to_s}
      begin
        auth_url = OauthToken.request_by((current_user ? current_user.id : nil),'#{site.to_s}')
        (session[:oauth_refers] ||= {}).update '#{site}' => request.referer
 
        if auth_url =~ /&oauth_callback/
          redirect_to auth_url
        else
          redirect_to auth_url + "&oauth_callback=" + default_callback_url('#{site.to_s}')
        end
      end
    end
  EOF
}
