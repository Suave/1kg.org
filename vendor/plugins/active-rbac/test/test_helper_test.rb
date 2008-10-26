#--
# Project:   active_rbac 
# File:      test/test_helper_helper.rb
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

# Require the to be tested helper.
require 'active_rbac/test_helper'

class TestHelperController < ActionController::Base
  acts_as_current_user_container
end

class TestHelperTest < UnitTest.TestCase
  def setup
    Object.const_set(:TestUser, Class.new(Object))

    @controller = TestController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  def teardown
    Object.send(:remove_const, :TestUser) if Object.const_defined?(:TestUser)
  end
  
  def test_set_current_user_works_correctly
    user = TestUser.new
    set_current_user(user)
    
    assert_equal user, @controller.current_user
  end
end