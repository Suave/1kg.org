#--
# Project:   active_rbac 
# File:      lib/active_rbac/module_registry_test.rb
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

require File.dirname(__FILE__) + '/unit_test_helper'

require File.dirname(__FILE__) + '/../lib/active_rbac'

require 'test/unit'

require 'mocha'
require 'stubba'

# Modify the ActiveRbac::ModelRegistry class so its state is resetable from
# the outside. This is imperative for testing.
class << ActiveRbac::ModelRegistry.instance
  def reset
    # Keep in sync with ModelRegistry#intialize!
    @user_class_info = nil
    @role_class_info = nil
    @static_permission_class_info = nil
  end
end

# Test the ActiveRbac::ModelRegistry class.
#
# The reason behind "< UnitTest.TestCase" is explained here:
# http://jayfields.blogspot.com/2006/06/ruby-on-rails-unit-tests.html
class ActiveRbacModelRegistryTest < UnitTest.TestCase
  def setup
    RAILS_DEFAULT_LOGGER.debug "--- setup ----------------------------------"
    
    ActiveRbac::ModelRegistry.instance.reset

    @first_user_fixture = 
      {
        :id => 1,
      }

    @first_role_fixture = 
      {
        :id => 1,
        :identifier => 'roles.first'
      }
    
    @first_static_permission_fixture = 
      {
        :id => 1,
        :identifier => 'permissions.first'
      }
    
    # Create the ActiveRecord classes on the fly.
    Object.const_set(:TestUser, Class.new(ActiveRecord::Base))
    setup_stubs_for_test_user

    Object.const_set(:TestRole, Class.new(ActiveRecord::Base))
    setup_stubs_for_test_role

    Object.const_set(:TestStaticPermission, Class.new(ActiveRecord::Base))
    setup_stubs_for_test_static_permission
  end
  
  def teardown
    Object.send(:remove_const, :TestUser) if Object.const_defined?(:TestUser)
    Object.send(:remove_const, :TestRole) if Object.const_defined?(:TestRole)
    Object.send(:remove_const, :TestStaticPermission) if Object.const_defined?(:TestStaticPermission)

    RAILS_DEFAULT_LOGGER.debug "--- teardown ----------------------------------"
  end
  
  def test_has_class_method_instance
    assert_respond_to ActiveRbac::ModelRegistry, :instance
    
    assert_kind_of ActiveRbac::ModelRegistry, ActiveRbac::ModelRegistry.instance
  end

  # Test that the correct methods are added when user and role are registered.
  def test_register_user_role_adds_relation_from_user_to_role
    teardown # so Test* is removed again
    
    [ :user, :role ].permutations.each do |symbols|
      setup
  
      assert_nil TestUser.reflect_on_association(:roles)
      user = TestUser.new
      assert !user.respond_to?(:has_role?)
  
      symbols.each do |symbol|
        case symbol
        when :user then TestUser.instance_eval { acts_as_user }
        when :role then TestRole.instance_eval { acts_as_role }
        end
      end
      
      msg = "symbols = #{symbols.inspect}"
  
      assert TestUser.attr_protected.include?(:roles), msg
  
      assert_respond_to user, :has_role?, msg
      assert_respond_to user, :is_anonymous?, msg
      assert_equal false, user.is_anonymous?, msg
  
      reflection = TestUser.reflect_on_association(:roles)
      assert_not_nil reflection, msg
      assert_equal :has_and_belongs_to_many, reflection.macro, msg
      assert reflection.class_name == 'TestRole', msg
      assert reflection.options[:uniq], msg
  
      teardown
    end
  end

  # Test that if first acts_as_role and then acts_as_user and then acts_as_static_permission
  # is called then the class registered as user gets the relation hatm :roles with appropriate 
  # parameters.
  def test_register_role_user_static_permission_adds_relation_from_user_to_role
    teardown # so Test* is removed again
    
    [ :user, :role, :static_permission ].permutations.each do |symbols|
      setup
      
      assert_nil TestUser.reflect_on_association(:roles)
      user = TestUser.new
      assert !user.respond_to?(:has_role?)
  
      symbols.each do |symbol|
        case symbol
        when :user then TestUser.instance_eval { acts_as_user }
        when :role then TestRole.instance_eval { acts_as_role }
        when :static_permission then TestStaticPermission.instance_eval { acts_as_static_permission }
        end
      end

      msg = "symbols = #{symbols.inspect}"

      assert TestUser.attr_protected.include?(:roles), msg
  
      reflection = TestUser.reflect_on_association(:roles)
      assert_not_nil reflection, msg
      assert_equal :has_and_belongs_to_many, reflection.macro, msg
      assert reflection.class_name == 'TestRole', msg
      assert reflection.options[:uniq], msg
  
      user = TestUser.new
      assert_respond_to user, :has_role?, msg
      assert_respond_to user, :static_permissions, msg
      assert_respond_to user, :has_static_permission?, msg

      assert TestRole.attr_protected.include?(:static_permissions), msg

      reflection = TestRole.reflect_on_association(:static_permissions)
      assert_not_nil reflection, msg
      assert_equal :has_and_belongs_to_many, reflection.macro, msg
      assert reflection.class_name == 'TestStaticPermission', msg
      assert reflection.options[:uniq], msg
  
      role = TestRole.new
      assert_respond_to role, :has_static_permission?, msg
      
      teardown
    end
  end
  
  protected
  
    # Stub out methods in the TestUser class that require connections
    # to the database.
    def setup_stubs_for_test_user
      the_columns = [
      ]
      TestUser.stubs(:columns).returns(the_columns)
  
      # trans-what? we want to stub them out =)
      TestUser.stubs(:transaction).yields()
  
      # stub out everything after validation
      TestUser.any_instance.stubs(:create_without_callbacks)
      TestUser.any_instance.stubs(:update_without_callbacks)
  
      # Always return the EncryptsPasswordUser fixture on find(:first).
      TestUser.stubs(:find).with(:first).returns(user_from_fixture(@first_user_fixture))
    end

    # Takes a fixture hash and returns a new EncryptsPasswordUser.
    def user_from_fixture(fixture)
      result = TestUser.new
      result.instance_eval do
        fixture.each { |key, value| write_attribute(key, value) }
        @new_record = false
      end
    
      result
    end

    # Stub out methods in the TestRole class that require connections
    # to the database.
    def setup_stubs_for_test_role
      the_columns = [
        ar_column('identifier', 'string'),
      ]
      TestRole.stubs(:columns).returns(the_columns)

      # trans-what? we want to stub them out =)
      TestRole.stubs(:transaction).yields()

      # stub out everything after validation
      TestRole.any_instance.stubs(:create_without_callbacks)
      TestRole.any_instance.stubs(:update_without_callbacks)

      # Always return the EncryptsPasswordUser fixture on find(:first).
      TestRole.stubs(:find).with(:first).returns(user_from_fixture(@first_role_fixture))
    end

    # Takes a fixture hash and returns a new EncryptsPasswordUser.
    def role_from_fixture(fixture)
      result = TestRole.new
      result.instance_eval do
        fixture.each { |key, value| write_attribute(key, value) }
        @new_record = false
      end
  
      result
    end

    # Stub out methods in the TestStaticPermission class that require connections
    # to the database.
    def setup_stubs_for_test_static_permission
      the_columns = [
        ar_column('identifier', 'string'),
      ]
      TestStaticPermission.stubs(:columns).returns(the_columns)

      # trans-what? we want to stub them out =)
      TestStaticPermission.stubs(:transaction).yields()

      # stub out everything after validation
      TestStaticPermission.any_instance.stubs(:create_without_callbacks)
      TestStaticPermission.any_instance.stubs(:update_without_callbacks)

      # Always return the EncryptsPasswordUser fixture on find(:first).
      TestStaticPermission.stubs(:find).with(:first).returns(static_permission_from_fixture(@first_static_permission_fixture))
    end

    # Takes a fixture hash and returns a new EncryptsPasswordUser.
    def static_permission_from_fixture(fixture)
      result = TestStaticPermission.new
      result.instance_eval do
        fixture.each { |key, value| write_attribute(key, value) }
        @new_record = false
      end
  
      result
    end

    # Shortcut for ActiveRecord::ConnectionAdapters::Column.new(name, default, type, nullable)
    def ar_column(name, type, default=nil, nullable=false)
      ActiveRecord::ConnectionAdapters::Column.new(name, default, type, nullable)
    end
end
