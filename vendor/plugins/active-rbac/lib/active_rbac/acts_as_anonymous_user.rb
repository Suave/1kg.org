#--
# Project:   active_rbac 
# File:      lib/active_rbac/acts_as_encrypts_password.rb
# Author:    Manuel Holtgrewe <purestorm at ggnore dot net>
# Copyright: (c) 2007 by Manuel Holtgrewe
# License:   MIT License as follows:
#
# Permission is hereby granted, free of charge, to any person obtaining 
# a copy of this software and associated documentation files (the 
# "Software"), to deal in the Software without restriction, including 
# without limitation the rights to use, copy, modify, merge, publish, 
# distribute, sublicense, and/or sell copies of the Software, and to permit
# persons to whom the Software is furnished to do so, subject to the 
# following conditions:
#
# The above copyright notice and this permission notice shall be included 
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
# OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. 
#++

# This mixin allows classes to act as anonymous users, i.e. their instances
# adhere to the ARBAC Schema Level 1/2 and the "assigned" roles and permissions
# are static.
#
# === Example
#
# Example of an AnonymousUser class that returns ActiveRecord::Base Role
# objects (the Role ActiveRecord::Base class must be defined somewhere, of 
# course).
#
#   class AnonymousUser 
#     acts_as_anonymous_user :roles => [ Role.find_by_identifier('roles.anonymous') ]
#   end
#
#
# Example of an AnonymousUser class that uses OpenStruct's to define the
# anonymous role outside the database:
#
#   require 'ostruct'
#   
#   class AnonymousUser 
#     acts_as_anonymous_user :roles => 
#       [
#         OpenStruct.new({ :identifier => 'roles.anonymous', 
#                          :permissions => [ OpenStruct.new({ :identifier => 'permissions.perm1' }), 
#                                            OpenStruct.new({ :identifier => 'permissions.perm2' }) ]})
#       ]
#   end
module ActsAsAnonymousUser #:nodoc:
  module ActsAsMethods
    def acts_as_anonymous_user(params={})
      include ActsAsAnonymousUser::Behaviour
      
      class_inheritable_accessor(:aaau_configuration)
      self.aaau_configuration = ::ActsAsAnonymousUser::Configuration.new(params)
    end
  end
  
  module Behaviour #:nodoc:
    def is_anonymous?
      true
    end

    def roles
      self.class.aaau_configuration.settings[:roles] # transform role identifiers into roles here
    end
    
    def has_role?(*identifiers)
      roles.any? { |r| identifiers.include?(r.identifier) }
    end
    
    def permissions
      self.class.aaau_configuration.settings[:roles].inject([]) do |arr, role|
        arr + role.permissions
      end
    end
    
    def has_static_permission?(*identifiers)
      permissions.any? { |p| identifiers.include?(p.identifier) }
    end
  end
  
  class Configuration #:nodoc:
    attr_reader :settings
    
    def initialize(parameters)
      defaults = {
        :roles => []
      }
      @settings = Hash.new
      
      # Override some settings.
      defaults.each do |key, value|
        if not parameters[key].nil? then
          @settings[key] = parameters[key]
        else
          @settings[key] = defaults[key]
        end
      end
    end
  end
end
