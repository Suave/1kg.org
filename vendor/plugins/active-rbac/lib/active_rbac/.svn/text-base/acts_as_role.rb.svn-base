#--
# Project:   active_rbac 
# File:      lib/active_rbac/acts_as_role.rb
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

# This is the mixin that is to be included in ActiveRecord::Base by 
# active_rbac.rb. After including, the acts_as_role method will be available
# in your ActiveRecord::Base subclasses.
module ActsAsRole
  def self.included(base_class)
    base_class.extend(ActsAsMethods)
  end
  
  module ActsAsMethods
    def acts_as_role
      # Register the class this method has been called with the ModelRegistry.
      ActiveRbac::ModelRegistry.instance.register_role_class(self)

      # Protect the relation static_permissions from mass assignment.
      attr_protected :static_permissions
      
      # Make sure the Role's identifier is specified.
      validates_presence_of :identifier
      
      # Make sure the Role's identifier is unique.
      validates_uniqueness_of :identifier
      
      nil
    end
  end
  
  # Extend the given class to act as the Role class.
  #
  # options is a Hash with the following keys:
  #
  # :static_permission_class::The related static permission class.
  def self.extend_role_class(klass, options)
    if klass.reflect_on_association(:static_permissions).nil? then
      RAILS_DEFAULT_LOGGER.debug "Extending class '#{klass}' with habtm :static_permissions and has_static_permission?."

      klass.class_eval do
        has_and_belongs_to_many :static_permissions, :class_name => options[:static_permission_class].to_s, :uniq => true
      
        # This method returns true if the StaticPermission is assigned the role with one of the
        # role titles given as parameters. False otherwise.
        def has_static_permission?(*permission_identifiers)
          static_permissions.any? { |permission| permission_identifiers.include?(permission.identifier) }
        end
      end
    end # :static_permissions
  end
end
