# -*- encoding : utf-8 -*-
module OauthSide
  module Model
    def self.included(base)
      base.extend ClassMethods
    end
    
    module ClassMethods
      def add_oauth
        raise "only one model can be bind to oauth" if (Rails.oauth_model && Rails.oauth_model != self.to_s)
        Rails.oauth_model=self.to_s
        Rails.oauth.each_key{|site|
          self.class_eval <<-EOF
            def #{site.to_s}
	            OauthToken.find_by_user_id_and_site(id, '#{site.to_s}').access_token
	          end

            def #{site.to_s}?
	            record = OauthToken.find_by_user_id_and_site id, '#{site.to_s}'
	            record && (!record.access_token.nil?)
            end
          EOF
        }
      end
    end
  end
end

ActiveRecord::Base.send(:include,OauthSide::Model)
