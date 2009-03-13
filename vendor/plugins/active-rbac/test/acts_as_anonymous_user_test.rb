#--
# Project:   active_rbac 
# File:      test/acts_as_anonymous_user_test.rb
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

require 'ostruct'

# The mock ActiveRecord::Base class we use to test acts_as_encrypts_password.
# We do pass any options to acts_as_anonymous_user.
class AnonymousUserWithDefaults
  acts_as_anonymous_user
end

# The mock ActiveRecord::Base class we use to test acts_as_encrypts_password.
# We do pass any options to acts_as_anonymous_user.
# We use OpenStruct to define fake roles and permissions.
class AnonymousUserWithConfiguration
  acts_as_anonymous_user :roles => 
    [
      OpenStruct.new({ :identifier => 'roles.anonymous', 
                       :permissions => [ OpenStruct.new({ :identifier => 'permissions.perm1' }), 
                                         OpenStruct.new({ :identifier => 'permissions.perm2' }) ]})
    ]
end

# The test case for the acts_as_anonymous_user mixin.
class ActsAsAnonymousUserTest < UnitTest.TestCase
  def setup
    @default_user = AnonymousUserWithDefaults.new
    @configured_user = AnonymousUserWithConfiguration.new
  end
  
  # Test that the correct methods have been added.
  def test_added_methods
    assert_respond_to @default_user, :roles
    assert_respond_to @default_user, :has_role?
    
    assert_respond_to @default_user, :permissions
    assert_respond_to @default_user, :has_static_permission?
  end
  
  # Test that the methods behave correctly with defaults.
  def test_methods_work_correctly_with_defaults
    assert_equal [], @default_user.roles
    assert_equal false, @default_user.has_role?('roles.anonymous')
    
    assert_equal [], @default_user.permissions
    assert_equal false, @default_user.has_static_permission?('permissions.foo')
  end
  
  # Test that the options passed to the mixin method are interpreted correctly
  # by the ActsAsAnonymousUser::Configuration class.
  def test_configuration_class_works_correctly
    # test that the defaults are correct
    default_conf = ActsAsAnonymousUser::Configuration.new({})
    assert_equal 1, default_conf.settings.length
    assert_equal [], default_conf.settings[:roles]
    
    # test that :roles is correctly set when passed in the creator
    params = { :roles => [ :role1, :role2 ] }
    conf = ActsAsAnonymousUser::Configuration.new(params)
    assert_equal params[:roles], conf.settings[:roles]
  end
  
  # Test that the instances of the host class of acts_as_anonymous_user return
  # the configured values.
  def test_methods_work_correctly_with_configuration
    perm1 = OpenStruct.new(:identifier => 'permissions.perm1')
    perm2 = OpenStruct.new(:identifier => 'permissions.perm2')
    anonymous_role = 
      OpenStruct.new(
        {
        :identifier => 'roles.anonymous', 
        :permissions => [ perm1, perm2 ],
        }
      )
    assert_equal [ anonymous_role ], @configured_user.roles
    assert_equal true, @configured_user.has_role?('roles.anonymous')
    assert_equal false, @configured_user.has_role?('roles.foo')

    assert_equal [ perm1, perm2 ], @configured_user.permissions
    assert_equal true, @configured_user.has_static_permission?('permissions.perm1')
    assert_equal true, @configured_user.has_static_permission?('permissions.perm2')
    assert_equal false, @configured_user.has_static_permission?('permissions.foo')
  end
end