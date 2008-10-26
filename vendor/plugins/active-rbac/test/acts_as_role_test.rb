#--
# Project:   active_rbac 
# File:      lib/active_rbac/acts_as_role_test.rb
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

# The test case for the acts_as_role mixin.
#
# The test case uses Stubba so no real database connection is required for 
# testing the ActiveRecord mixin.
#
# "Modified" means modifications of the password in the methods' documentation
# below.
#
# The reason behind "< UnitTest.TestCase" is explained here:
# http://jayfields.blogspot.com/2006/06/ruby-on-rails-unit-tests.html
class ActsAsRoleTest < UnitTest.TestCase
  def setup
    ActiveRbac::ModelRegistry.instance.reset

    @fixtures = {
      :test_role => [
        {
          :id => 1,
          :identifier => 'roles.first'
        }
      ]
    }
    @first_role_fixture = @fixtures[:test_role].first

    # Create the ActiveRecord classes on the fly.
    Object.const_set(:TestRole, Class.new(ActiveRecord::Base))
    @role_class = TestRole
    setup_stubs_for_test_role
  end
  
  def teardown
    Object.send(:remove_const, :TestRole) if Object.const_defined?(:TestRole)
  end
  
  def test_acts_as_rolle_call_registers_class_with_model_registry
    ActiveRbac::ModelRegistry.instance.expects(:register_role_class).times(1).with(TestRole)
    TestRole.expects(:validates_presence_of).times(1).with(:identifier)
    TestRole.expects(:validates_uniqueness_of).times(1).with(:identifier)
    
    TestRole.instance_eval { acts_as_role }
  end
  
  protected

    # Stub out methods in the ActsAsRole class that require connections
    # to the database.
    def setup_stubs_for_test_role
      the_columns = [
      ]
      @role_class.stubs(:columns).returns(the_columns)
    
      # trans-what? we want to stub them out =)
      @role_class.stubs(:transaction).yields()
    
      # stub out everything after validation
      @role_class.any_instance.stubs(:create_without_callbacks)
      @role_class.any_instance.stubs(:update_without_callbacks)
    
      # Always return the EncryptsPasswordRole fixture on find(:first).
      @role_class.stubs(:find).with(:first).returns(role_from_fixture(@first_role_fixture))
    end

    # Shortcut for ActiveRecord::ConnectionAdapters::Column.new(name, default, type, nullable)
    def ar_column(name, type, default=nil, nullable=false)
      ActiveRecord::ConnectionAdapters::Column.new(name, default, type, nullable)
    end

    # Takes a fixture hash and returns a new EncryptsPasswordRole.
    def role_from_fixture(fixture)
      result = @role_class.new
      result.instance_eval do
        fixture.each { |key, value| write_attribute(key, value) }
        @new_record = false
      end
      
      result
    end
end
