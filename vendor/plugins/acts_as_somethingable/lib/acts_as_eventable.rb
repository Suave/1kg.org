# -*- encoding : utf-8 -*-
module ActiveRecord
  module Acts
    module Eventable
      def self.included(base)
        base.extend(ClassMethods)
      end
      
      module ClassMethods
        def acts_as_eventable
          has_one :event, :as => :eventable, :dependent => :destroy
          include ActiveRecord::Acts::Eventable::InstanceMethods
          after_create :init_event
          
        end  
      end
      
      module InstanceMethods
        def init_event
          Event.create(:eventable => self,:user_id => self.user_id,:venue_id => self.venue_id)
        end
      end
    end
  end
end
ActiveRecord::Base.send(:include, ActiveRecord::Acts::Eventable)
