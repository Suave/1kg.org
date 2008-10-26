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

require File.dirname(__FILE__) + '/unit_test_helper'

require File.dirname(__FILE__) + '/../lib/active_rbac'

require 'test/unit'

require 'mocha'
require 'stubba'

# The AR class to be used to test storing users.
class PersistedUser < ActiveRecord::Base
end

# The mock ActionController::Base class we use to test
# acts_as_current_user_container.
module TestHelper; end
class TestController < ActionController::Base
  acts_as_current_user_container
end

# The test case for the acts_as_current_user_container mixin.
#
# The reason behind "< UnitTest.TestCase" is explained here:
# http://jayfields.blogspot.com/2006/06/ruby-on-rails-unit-tests.html
class ActsAsCurrentUserContainerTest < UnitTest.TestCase
  def setup
    @controller_classes = [ TestController ]
    @controllers = @controller_classes.map { |c| c.new }

    @controller = TestController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    setup_stubs_for_persisted_user
    @user_fixture = PersistedUser.new
  end
  
  # Test that current_user and current_user= have been added to the controller.
  def test_added_methods
    assert_respond_to @controller, :current_user
    assert_respond_to @controller, :current_user=
    
    # make sure these methods are protected
    assert_raises(NoMethodError) { @controller.current_user }
    assert_raises(NoMethodError) { @controller.current_user=nil }
  end

  # Test that ActsAsCurrentUserContainer::CurrentUserClassState returns the
  # currect anonymous_user object for various parameters.
  def test_current_user_class_state_returns_correct_current_user
    clazz = ActsAsCurrentUserContainer::CurrentUserClassState
    
    assert_nil clazz.new({}).anonymous_user
    assert_nil clazz.new({:anonymous_user => nil}).anonymous_user
    assert_kind_of String, clazz.new({:anonymous_user => :string}).anonymous_user
    assert_kind_of String, clazz.new({:anonymous_user => String}).anonymous_user
  end
  
  # Test that the controller persists the given user class correctly with
  # ActiveRecord not new objects.
  def test_persisting_active_record_works_if_not_new
    user = PersistedUser.new
    user.stubs(:new_record?).returns(false)
    user.stubs(:id).returns(42)

    session_hash = Hash.new

    @controller.stubs(:session).returns(session_hash)
    @controller.current_user = user
    
    assert_kind_of Array, session_hash[:aacuc_data]
    assert_equal 2, session_hash[:aacuc_data].length
    assert_equal PersistedUser, session_hash[:aacuc_data][0]
    assert_equal 42, session_hash[:aacuc_data][1]
  end
  
  # Test that an exception is thrown if an unpersisted object is to be
  # persisted.
  def test_persisting_active_record_does_not_work_if_new
    user = PersistedUser.new
    user.stubs(:new_record?).returns(true)

    caught_exception = false

    begin
      @controller.current_user = user
    rescue RuntimeError => bang
      assert_equal "You cannot set ActiveRecord::Base objects as current_user if they are new (not stored in database).", bang.message
      
      caught_exception = true
    end
    
    assert caught_exception
  end
  
  # Test that the controller persists the given user class correctly with
  # PersistableInSession objects.
  def test_persisting_persistable_in_session_objects_works
    mock_user = mock("Mock User.")
    mock_user.stubs(:persist).returns(:persisted_info)
    mock_user.class.stubs(:unpersist)

    session_hash = Hash.new

    @controller.stubs(:session).returns(session_hash)
    @controller.current_user = mock_user
    
    assert_kind_of Array, session_hash[:aacuc_data]
    assert_equal 2, session_hash[:aacuc_data].length
    assert_equal mock_user.class, session_hash[:aacuc_data][0]
    assert_equal :persisted_info, session_hash[:aacuc_data][1]
  end

  # Test that the controller persists the given user class correctly with
  # plain objects.
  def test_persisting_plain_objects_works
    mock_user = "Fake user. A String, really."
    
    session_hash = Hash.new

    @controller.stubs(:session).returns(session_hash)
    @controller.current_user = mock_user
    
    assert_kind_of Array, session_hash[:aacuc_data]
    assert_equal 2, session_hash[:aacuc_data].length
    assert_equal mock_user.class, session_hash[:aacuc_data][0]
    assert_equal nil, session_hash[:aacuc_data][1]
  end
  
  # Test that an exception is thrown if an incomplete persistable_in_session
  # interface is provided by the object to be persisted.
  def test_persisting_raises_if_incomplete_persistable_in_session_interface_used__persist_is_missing
    mock_user = mock("Mock User.")
    mock_user.class.stubs(:unpersist)

    session_hash = Hash.new

    @controller.stubs(:session).returns(session_hash)
    assert_raises(RuntimeError) {
      @controller.current_user = mock_user
    }
    
    assert_nil session_hash[:aacuc_data]
  end

  # Test that an exception is thrown if an incomplete persistable_in_session
  # interface is provided by the object to be persisted.
  def test_persisting_raises_if_incomplete_persistable_in_session_interface_used__unpersist_is_missing
    mock_user = mock("Mock User.")
    mock_user.stubs(:persist).returns(:persisted_info)

    session_hash = Hash.new

    @controller.stubs(:session).returns(session_hash)
    assert_raises(RuntimeError) {
      @controller.current_user = mock_user
    }
    
    assert_nil session_hash[:aacuc_data]
  end

  def test_setting_current_user_to_nil_works
    session_hash = Hash.new

    @controller.stubs(:session).returns(session_hash)
    @controller.current_user = nil
    
    assert_equal nil, session_hash[:aacuc_data]
  end
  
  # Test that the controller persists the given user class correctly with
  # ActiveRecord objects.
  def test_unpersisting_active_record_works
    PersistedUser.stubs(:find).with(42).times(1).returns(:unpersisted_user)
    
    session_hash = Hash.new
    session_hash[:aacuc_data] = [ PersistedUser, 42 ]

    unpersisted_user = nil

    @controller.stubs(:session).returns(session_hash)
    @controller.instance_eval { unpersisted_user = current_user } # instance_eval to call protected method
    
    assert_equal :unpersisted_user, unpersisted_user
  end
  
  # Test that the controller persists the given user class correctly with
  # PersistableInSession objects.
  def test_unpersisting_persistable_in_session_objects_works
    String.stubs(:unpersist).with(:persisted_info).times(1).returns("unpersisted string")
    String.any_instance.stubs(:persist)
    
    session_hash = Hash.new
    session_hash[:aacuc_data] = [ String, :persisted_info ]

    unpersisted_user = nil

    @controller.stubs(:session).returns(session_hash)
    @controller.instance_eval { unpersisted_user = current_user } # instance_eval to call protected method
    
    assert_equal "unpersisted string", unpersisted_user
  end

  # Test that the controller persists the given user class correctly with
  # plain objects.
  def test_unpersisting_plain_objects_works
    session_hash = Hash.new
    session_hash[:aacuc_data] = [ String, nil ]

    unpersisted_user = nil

    @controller.stubs(:session).returns(session_hash)
    @controller.instance_eval { unpersisted_user = current_user } # instance_eval to call protected method
    
    assert_equal "", unpersisted_user
  end
  
  # Test that an exception is thrown if an incomplete persistable_in_session
  # interface is provided by the object to be persisted.
  def test_unpersisting_raises_if_incomplete_persistable_in_session_interface_used
    # persist is missing
    String.stubs(:unpersist).with(:persisted_info).times(1).returns("unpersisted string")

    session_hash = Hash.new
    session_hash[:aacuc_data] = [ String, :persisted_info ]
    
    the_user = nil

    @controller.stubs(:session).returns(session_hash)
    assert_raises(RuntimeError) {
      @controller.instance_eval { the_user = current_user } # instance_eval to call protected method
    }
  end
  
  protected

    # Stub out methods in the EncryptPasswordUser class that require connections
    # to the database.
    def setup_stubs_for_persisted_user
      PersistedUser.stubs(:columns).returns([])
    end
end