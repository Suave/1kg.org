# -*- encoding : utf-8 -*-
module ActiveRecord
  module Acts
    module Ownable
      def self.included(base)
        base.extend(ClassMethods)
      end
      
      module ClassMethods
        def acts_as_ownable
          include ActiveRecord::Acts::Ownable::InstanceMethods
        end  
      end
      
      module InstanceMethods
        def owned_by?(user)
          user && (self.user == user || user.is_admin)
        end
      end
    end
  end
end
ActiveRecord::Base.send(:include, ActiveRecord::Acts::Ownable)
