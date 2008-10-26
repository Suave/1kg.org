#--
# Project:   active_rbac 
# File:      lib/active_rbac/acts_as_role.rb
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

require 'singleton'

module ActiveRbac
  # The ModelRegistry is a singleton class that manages marking of roles, users
  # and static permission classes.
  #
  # Whenever acts_as_user, acts_as_role or acts_as_static_permission gets called,
  # these methods call #register_user_class, #register_role_class or
  # #register_static_permission_class. These methods will then add the appropriate
  # relations to the other registered classes.
  #
  # For example, if the class MyUser and MyStaticPermission have been marked by
  # acts_as_user regarding acts_as_static_permission and the class MyRole gets
  # marked by acts_as_role then the following will happen:
  #
  # * The MyUser class will get the following relation: <code>has_and_belongs_to_many
  #   :roles, :class_name => 'MyRole'</code>
  # * The MyUser class will get the method has_role?.
  # * The MyUser class will get the following relation: <code>has_and_belongs_to_many
  #   :permissions, :class_name => 'MyPermission', :through => :roles</code>
  # * The MyUser class will get the method has_static_permission?.
  #
  # * The MyRole class will get the following relation: <code>has_and_belongs_to_many
  #   :permissions, :class_name => 'MyPermission'</code>
  # * The MyRole class will get the method has_static_permission?.
  #
  # === Notes
  #
  # * The class ActiveRbac::ModelRegistry is marked to be unloaded by the Rails Dependencies module.
  #
  # === Restrictions
  #
  # * At the moment, table name must be inflectable from record class name.
  # * No custom join tables!
  class ModelRegistry
    include Singleton

    def initialize
      @user_class_info = nil
      @role_class_info = nil
      @static_permission_class_info = nil
    end
    
    # Registers the given ActiveRecord::Base class as the one to use for storing users.
    # This method is automatically called by acts_as_user.
    #
    # === Exceptions
    #
    # Raises an ArgumentError if klass is not a descendant of ActiveRecord::Base
    def register_user_class(klass)
      raise ArgumentError, "#{klass} is not a descendant of ActiveRecord::Base!" unless ActiveRecord::Base > klass
      
      if not @user_class_info.nil? and klass == @user_class_info[:class] then
        logger.debug "Ignoring registration of user class '#{klass}' since it is already registered."
        return
      end
      
      logger.debug "Unregistering previous user class '#{@user_class_info[:class]}'." if not @user_class_info.nil?
      logger.debug "Registering class '#{klass}' as new user class."
      
      # Set new information about the user class.
      @user_class_info = 
        {
          :class => klass
        }
      
      # Update the classes that are affected by the updated user class.
      update_classes(:user)
    end

    # Registers the given ActiveRecord::Base class as the one to use for storing roles.
    # This method is automatically called by acts_as_role.
    #
    # === Exceptions
    #
    # Raises an ArgumentError if klass is not a descendant of ActiveRecord::Base
    def register_role_class(klass)
      raise ArgumentError, "#{klass} is not a descendant of ActiveRecord::Base!" unless ActiveRecord::Base > klass
      
      if not @role_class_info.nil? and klass == @role_class_info[:class] then
        logger.debug "Ignoring registration of role class '#{klass}' since it is already registered."
        return
      end
      
      logger.debug "Unregistering previous role class '#{@role_class_info[:class]}'." if not @role_class_info.nil?
      logger.debug "Registering class '#{klass}' as new role class."
      
      # Set new information about the role class.
      @role_class_info = 
        {
          :class => klass
        }
      
      # Update the classes that are affected by the updated role class.
      update_classes(:role)
    end

    # Registers the given ActiveRecord::Base class as the one to use for storing
    # static permissions. This method is automatically called by acts_as_static_permission.
    #
    # === Exceptions
    #
    # Raises an ArgumentError if klass is not a descendant of ActiveRecord::Base
    def register_static_permission_class(klass)
      raise ArgumentError, "#{klass} is not a descendant of ActiveRecord::Base!" unless ActiveRecord::Base > klass
      
      if not @static_permission_class_info.nil? and klass == @static_permission_class_info[:class] then
        logger.debug "Ignoring registration of static permission class '#{klass}' since it is already registered."
        return
      end
      
      logger.debug "Unregistering previous static permission class '#{@static_permission_class_info[:class]}'." if not @static_permission_class_info.nil?
      logger.debug "Registering class '#{klass}' as new static permission class."
      
      # Set new information about the role class.
      @static_permission_class_info = 
        {
          :class => klass
        }
      
      # Update the classes that are affected by the updated role class.
      update_classes(:static_permission)
    end
    
    protected
    
      # Update the classes that are affected by the registration of the class as "last_changed".
      # last_changed can be one of :user, :role and :static_permission
      def update_classes(last_changed=nil)
        if    (not @user_class_info.nil? and not @role_class_info.nil? and not @static_permission_class_info.nil?) then # 111
          # Order is important here! User class will only be updated if the
          # role class already has an association to static permission.
          update_role_class if [ nil, :static_permission, :role ].include?(last_changed)
          update_user_class
        elsif (not @user_class_info.nil? and not @role_class_info.nil? and     @static_permission_class_info.nil?) then # 110
          update_user_class
        elsif (    @user_class_info.nil? and not @role_class_info.nil? and not @static_permission_class_info.nil?) then # 011
          update_role_class
        end
      end
      
      # Updates the user class.
      def update_user_class
        ActsAsUser.extend_user_class(@user_class_info[:class], 
          {
            :role_class => @role_class_info[:class],
          })
      end
      
      # Update the role class.
      def update_role_class
        ActsAsRole.extend_role_class(@role_class_info[:class], 
          {
            :static_permission_class => (@static_permission_class_info[:class] rescue nil),
          })
      end
    
      # Utility method; returns RAILS_DEFAULT_LOGGER
      def logger
        RAILS_DEFAULT_LOGGER
      end
  end
end
