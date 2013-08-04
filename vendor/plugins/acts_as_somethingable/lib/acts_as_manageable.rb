# -*- encoding : utf-8 -*-
module ActiveRecord
  module Acts
    module Manageable
      def self.included(base)
        base.extend(ClassMethods)
      end
      
      module ClassMethods
        def acts_as_manageable
          include ActiveRecord::Acts::Manageable::InstanceMethods
        end  
      end
      
      module InstanceMethods
        def managements
          Management.find(:all,:conditions => {:manageable_id => self.id,:manageable_type => self.class.name})
        end

        def managers
          Management.find(:all,:conditions => {:manageable_id => self.id,:manageable_type => self.class.name},:include => [:user]).map(&:user)
        end

        def managed_by?(user)
          user && Management.find(:all,:conditions => {:manageable_id => self.id,:manageable_type => self.class.name,:user_id => user.id}).present?
        end
      end
    end
  end
end
ActiveRecord::Base.send(:include, ActiveRecord::Acts::Manageable)
