#--
# Project:   active_rbac 
# File:      lib/active_rbac/acts_as_current_user_container.rb
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

require 'digest/sha1'

module ActsAsCurrentUserContainer #:nodoc:
  module ActsAsMethods
    # Using this method in one of your ActionController classes will add the
    # protected methods current_user and current_user= to your controller.
    #
    # === How Persisting Works
    #
    # * <strong>NOTE</strong> that you can only use already persistent ActiveRecord::Baase
    #   objects as current users.
    #
    # === Example
    #
    #   class ApplicationController
    #     acts_as_current_user_container
    #   end
    #
    #   class LoginController
    #     def login
    #       current_user = User.find(params[:user_id]) if login_valid?(params)
    #     end
    #   end
    #
    #   class AdminController
    #     before_filter :protect_controller
    #     
    #     private
    #
    #       def protect_controller
    #         # return false iff the user is not allowed here
    #         return !current_user.nil? && current_user.has_role?('roles.admin')
    #       end
    #   end
    #
    # === Testing Authentication
    #
    # You can call current_user and current_user= on your controllers which have the
    # acts_as_current_user_container mixin. A example:
    #
    #   class MyControllerTest < Test::Unit::TestCase
    #     fixtures :users, :roles, :roles_users
    #     
    #     def setup
    #       @controller = MyController.new
    #       
    #       @session_hash = Hash.new
    #       @controller.stubs(:session).returns(@session_hash)
    #       
    #       @request    = ActionController::TestRequest.new
    #       @response   = ActionController::TestResponse.new
    #     end
    #
    #     def test_access_allowed_to_registered_user
    #       @controller.current_user = User.find(users(:registered).id)
    #       
    #       get :action
    #
    #       assert_response :success
    #     end
    #
    #     def test_access_restricted_for_anonymous_user
    #       @controller.current_user = AnonymousUser.new
    #       
    #       get :action
    #
    #       assert flash[:error]
    #       assert_response :redirect
    #       assert_redirected_to :action => 'forbidden'
    #     end
    #   end
    #
    # === Parameters
    #
    # The methods accepts the following parameters:
    #
    # :anonymous_user:: Sets which class to use for the result of current_user
    #                   if nothing has been set using current_user= yet.
    #
    # :anonymous_user can be nil (default), a symbol or a class. If it is nil
    # then nil is returned by current_user for anonymous users. If it is a 
    # class then a new object of the given class is returned for anonymous
    # users. If it is a symbol then <symbol>.to_s.classify is returned.
    #
    # Examples for values that would make sense are nil, AnonymousUser and
    # :anonymous_user (if an AnonymousUser class has been defined earlier).
    def acts_as_current_user_container(params={})
      class_eval do
        # Include the behaviour (i.e. the actual mixin methods).
        include ActsAsCurrentUserContainer::Behaviour
        helper ActsAsCurrentUserContainer::Helper

        write_inheritable_attribute(:aacuc_class_state, CurrentUserClassState.new(params))

        class_inheritable_reader :aacuc_class_state
        
        hide_action :current_user, :current_user=
      end
    end
  end
  
  module Behaviour

    public
      def current_user
        @aacuc_obj_state ||= CurrentUserObjectState.new
        
        # First, try to return the current user stored in @aacuc_obj_state.
        # Then, try to return the current user as it is stored in the session.
        # If this fails then return an anonymous user from @@aacuc_class_state.
        if not @aacuc_obj_state.current_user.nil? then
          @aacuc_obj_state.current_user
        elsif not session[:aacuc_data].nil? then
          @aacuc_obj_state.current_user = 
            ActsAsCurrentUserContainer::StaticMethods.unpersist(session[:aacuc_data])
          logger.debug "Unpersisted #{session[:aacuc_data].inspect} to #{@aacuc_obj_state.current_user}"

          @aacuc_obj_state.current_user
        else
          logger.debug "Unpersisted nothing, returning anonymous user: #{aacuc_class_state.anonymous_user.inspect}"
          aacuc_class_state.anonymous_user
        end
      end
    
      def current_user=(value)
        @aacuc_obj_state ||= ActsAsCurrentUserContainer::CurrentUserObjectState.new
        
        @aacuc_obj_state.current_user = value
        persisted_value = ActsAsCurrentUserContainer::StaticMethods.persist(value)
        session[:aacuc_data] = persisted_value
        logger.debug "Setting session[:aacuc_data] to #{persisted_value.inspect}"
        
        value
      end
  end
  
  # Contains static methods that used throughout the mixin.
  module StaticMethods #:nodoc:
    # Persists a value set as current_user to current_user.
    def self.persist(current_user)
      if current_user.nil? then
        nil
      elsif ActiveRecord::Base > current_user.class then
        if current_user.new_record? then
          raise "You cannot set ActiveRecord::Base objects as current_user if they are new (not stored in database)."
        end
        
        # ActiveRecord::Base objects are persisted with their id only.
        [ current_user.class, current_user.id ]
      else
        # Check whether the object and its class provide the 
        # PersistableInSession interface (raise errors when they only proivde a
        # part of the interface) and return value that can be unpersisted.
        if current_user.respond_to?(:persist) and not current_user.class.respond_to?(:unpersist) then
          raise "current_user reponds to :persist but current_user.class does not respond to :unpersist"
        elsif not current_user.respond_to?(:persist) and current_user.class.respond_to?(:unpersist) then
          raise "current_user does not respond to :persist but current_user.class responds to :unpersist"
        elsif current_user.respond_to?(:persist) and current_user.class.respond_to?(:unpersist) then
          [ current_user.class, current_user.persist ]
        else
          [ current_user.class, nil ]
        end
      end
    end

    # Unpersists a value set as current_user from data_from_session.
    def self.unpersist(data_from_session)
      clazz, persistent_information = data_from_session
      
      if ActiveRecord::Base > clazz then
        # We know how to unpersist ActiveRecord::Base classes.
        clazz.find persistent_information
      elsif clazz.respond_to?(:unpersist)
        # And of those implementing the PersistableInSession interface.
        result = clazz.unpersist(persistent_information)
        
        if not result.respond_to?(:persist)
          raise "to-be-unpersisted current_user does not respond to :persist but current_user.class responds to :unpersist"
        end
        
        result
      else
        # Otherwise, we simply recreate the class.
        clazz.new
      end
    end
  end
  
  # Contains the state for the acts_as_current_user_container mixin within
  # ActionController::Base classes.
  class CurrentUserClassState #:nodoc:
    # The creator merges params with defaults.
    def initialize(params)
      # set defaults
      @parameters = {
        :anonymous_user => nil,
      }
      
      # process parameters
      @parameters[:anonymous_user] = 
        if params[:anonymous_user].nil? then
          nil
        elsif params[:anonymous_user].kind_of? Symbol then
          Object.const_get(params[:anonymous_user].to_s.classify)
        elsif params[:anonymous_user].kind_of? Class then
          params[:anonymous_user]
        else
          raise "Invalid value for :anonymous_user: #{params[:anonymous_user].inspect}"
        end
    end

    # The parameters given to the acts_as_current_user_container mixin.
    attr_accessor :parameters
    
    # Returns the current user based on the object's params.
    def anonymous_user
      @anonymous_user ||= 
        if parameters[:anonymous_user].nil? then
          nil
        else
          parameters[:anonymous_user].new
        end
    end
  end

  # Contains the state for the acts_as_current_user_container mixin within
  # ActionController::Base objects.
  class CurrentUserObjectState #:nodoc:
    attr_accessor :current_user
  end
  
  # Provide access to current_user in the views.
  module Helper #:nodoc:
    def current_user
      controller.current_user
    end
  end
end