#--
# Project:    active_rbac
# File:       test/unit_test_helper.rb
# Author:     Manuel Holtgrewe <purestorm@ggnore.net>
#
# Copyright (c) 2006 Manuel Holtgrewe
# 
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
# BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
# ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#++
# Helper file for database access less Rails unit tests. Taken from
# http://jayfields.blogspot.com/2006/06/ruby-on-rails-unit-tests.html

ENV["RAILS_ENV"] = "test" 
require File.expand_path(File.dirname(__FILE__) + "/../../../../config/environment") 
require 'application' 
require 'test/unit' 
require 'action_controller/test_process' 
require 'breakpoint'

class UnitTest
  def self.TestCase
    # Make sure ActiveRecord::Base.connection is useless.
    class << ActiveRecord::Base
      def connection
        raise InvalidMethodCallError, 'You cannot access the database from a unit test', caller
      end
    end
    
    # OK, we can return the real TestCase class now.
    Test::Unit::TestCase
  end
end

# http://blog.jayfields.com/2006/09/testunit-test-creation.html
# Author: Jay Fields
class << Test::Unit::TestCase
 def test(name, &block)
   test_name = :"test_#{name.gsub(' ','_')}"
   raise ArgumentError, "#{test_name} is already defined" if self.instance_methods.include? test_name.to_s
   define_method test_name, &block
 end
end

# http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-talk/32844
# Author: Steven Grady

class Array
  def permutations
    return [self] if size < 2
    perm = []
    each { |e| (self - [e]).permutations.each { |p| perm << ([e] + p) } }
    perm
  end
end

class InvalidMethodCallError < StandardError
end

# This unit test makes sure that the attempt to connect to the database leads 
# to an exception in a UnitTest.TestCase.
class AttemptToAccessDbThrowsExceptionTest < UnitTest.TestCase
  def test_calling_the_db_causes_a_failure
    assert_raise(InvalidMethodCallError) { ActiveRecord::Base.connection }
  end
end