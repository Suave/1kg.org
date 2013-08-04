# -*- encoding : utf-8 -*-
module ActiveRecord
  module Acts
    module Spamable
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def acts_as_spamable
          include ActiveRecord::Acts::Spamable::InstanceMethods
        end
      end
      module InstanceMethods
        def check_spam_word_for(attr)
          SPAM_WORDS.each do |w|
            text = self.attributes[attr].gsub(/ |　/,'')
            if text.include?(w)
              return false
            end
          end
          true
        end
      end
    end
  end
end
ActiveRecord::Base.send(:include, ActiveRecord::Acts::Spamable)
