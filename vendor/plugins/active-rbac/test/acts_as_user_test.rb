#--
# Project:   active_rbac 
# File:      lib/active_rbac/acts_as_user_test.rb
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

# The test case for the acts_as_user mixin.
#
# The test case uses Stubba so no real database connection is required for 
# testing the ActiveRecord mixin.
#
# "Modified" means modifications of the password in the methods' documentation
# below.
#
# The reason behind "< UnitTest.TestCase" is explained here:
# http://jayfields.blogspot.com/2006/06/ruby-on-rails-unit-tests.html
class ActsAsUserTest < UnitTest.TestCase
  def setup
    ActiveRbac::ModelRegistry.instance.reset
    
    @fixtures = {
      :test_user => [
        {
          :id => 1
        }
      ]
    }
    @first_user_fixture = @fixtures[:test_user].first

    # Create the ActiveRecord classes on the fly.
    Object.const_set(:TestUser, Class.new(ActiveRecord::Base))
    @user_class = TestUser
    setup_stubs_for_test_user
  end
  
  def teardown
    Object.send(:remove_const, :TestUser) if Object.const_defined?(:TestUser)
  end
  
  def test_mixin_adds_expected_methods
    TestUser.instance_eval { acts_as_user }
    user = @user_class.new
    
    assert_respond_to user, :is_anonymous?
  end
  
  def test_is_anonymous_returns_false
    TestUser.instance_eval { acts_as_user }
    user = @user_class.new
    
    assert_equal false, user.is_anonymous?
  end
  
  def test_acts_as_user_call_registers_class_with_model_registry
    ActiveRbac::ModelRegistry.instance.expects(:register_user_class).times(1).with(TestUser)
    
    TestUser.instance_eval { acts_as_user }
  end
  
  protected

    # Stub out methods in the EncryptPasswordUser class that require connections
    # to the database.
    def setup_stubs_for_test_user
      the_columns = [
      ]
      @user_class.stubs(:columns).returns(the_columns)
    
      # trans-what? we want to stub them out =)
      @user_class.stubs(:transaction).yields()
    
      # stub out everything after validation
      @user_class.any_instance.stubs(:create_without_callbacks)
      @user_class.any_instance.stubs(:update_without_callbacks)
    
      # Always return the EncryptsPasswordUser fixture on find(:first).
      @user_class.stubs(:find).with(:first).returns(user_from_fixture(@first_user_fixture))
    end

    # Shortcut for ActiveRecord::ConnectionAdapters::Column.new(name, default, type, nullable)
    def ar_column(name, type, default=nil, nullable=false)
      ActiveRecord::ConnectionAdapters::Column.new(name, default, type, nullable)
    end

    # Takes a fixture hash and returns a new EncryptsPasswordUser.
    def user_from_fixture(fixture)
      result = @user_class.new
      result.instance_eval do
        fixture.each { |key, value| write_attribute(key, value) }
        @new_record = false
      end
      
      result
    end
end
