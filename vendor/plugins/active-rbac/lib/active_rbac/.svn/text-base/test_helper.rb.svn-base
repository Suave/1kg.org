#--
# Project:   active_rbac 
# File:      lib/active_rbac/test_helper.rb
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
# This class extends the Test::Unit::TestCase class to provide helper methods
# for tests with ActiveRbac.

require 'test/unit'

class Test::Unit::TestCase
  # Sets the current user as ActionController::Base#current_user= would. The
  # current controller must be available in @controller, the current request
  # must be available in @request.
  def set_current_user(user)
    @controller.instance_eval do
      @aacuc_obj_state ||= ActsAsCurrentUserContainer::CurrentUserObjectState.new
      @aacuc_obj_state.current_user = user
    end
    
    persisted_value = ActsAsCurrentUserContainer::StaticMethods.persist(user)
    @request.session[:aacuc_data] = persisted_value
    
    RAILS_DEFAULT_LOGGER.debug "TestCase#set_current_user: Setting session[:aacuc_data] to #{persisted_value.inspect}"
    
    user
  end
end
