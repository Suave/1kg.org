module OauthSide
  module Ext
    module Hash
  
  # ==== Parameters
  # *allowed:: The hash keys to include.
  #
  # ==== Returns
  # Hash:: A new hash with only the selected keys.
  #
  # ==== Examples
  #   { :one => 1, :two => 2, :three => 3 }.only(:one)
  #     #=> { :one => 1 }
      def only(*allowed)
        allowed = allowed[0] if allowed.size == 1 and allowed[0].is_a? Array
        reject { |k,v| !allowed.include?(k) }
      end
	end
  end
end

Hash.send(:include, OauthSide::Ext::Hash)
