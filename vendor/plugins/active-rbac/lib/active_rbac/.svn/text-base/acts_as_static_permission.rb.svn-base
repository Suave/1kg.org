#--
# Project:   active_rbac 
# File:      lib/active_rbac/acts_as_static_permission.rb
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

module ActsAsStaticPermission
  def self.included(base_class)
    base_class.extend(ActsAsMethods)
  end
  
  module ActsAsMethods
    def acts_as_static_permission
      # Extend StaticPermission class with methods that do not depend on the existance of other
      # Schema classes (namely Role).
      include ActsAsStaticPermission::IndependentBehaviour

      # Make sure the StaticPermission's identifier is specified.
      validates_presence_of :identifier

      # Make sure the Role's identifier is unique.
      validates_uniqueness_of :identifier
      
      # Register this class as the role class with ModelRegistry.
      ActiveRbac::ModelRegistry.instance.register_static_permission_class(self)
      
      nil
    end
  end
  
  # Module with the method defining behaviour that does not depend on other classes.
  module IndependentBehaviour
  end
end