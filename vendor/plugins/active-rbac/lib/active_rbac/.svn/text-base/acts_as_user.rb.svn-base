#--
# Project:   active_rbac 
# File:      lib/active_rbac/acts_as_user.rb
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

module ActsAsUser
  def self.included(base_class)
    base_class.extend(ActsAsMethods)
  end
  
  module ActsAsMethods
    def acts_as_user
      # Extend User class with methods that do not depend on the existance of other
      # Schema classes (namely Role).
      include ActsAsUser::IndependentBehaviour
      
      # Register this class as the role class with ModelRegistry.
      ActiveRbac::ModelRegistry.instance.register_user_class(self)
      
      nil
    end
  end
  
  # Extend the given class to act as the user class.
  #
  # options is a Hash with the following keys:
  #
  # :role_class::The related role class.
  def self.extend_user_class(klass, options)
    RAILS_DEFAULT_LOGGER.info "============================================================================="
    RAILS_DEFAULT_LOGGER.info klass.reflect_on_association(:roles).inspect
    RAILS_DEFAULT_LOGGER.info "============================================================================="
    
    if klass.reflect_on_association(:roles).nil? then
      RAILS_DEFAULT_LOGGER.debug "Extending class '#{klass}' with habtm :roles and has_role?."
      
      klass.class_eval do
        # Protect the relation roles from mass assignment.
        attr_protected :roles

        has_and_belongs_to_many :roles, :class_name => options[:role_class].to_s, :uniq => true
      
        # This method returns true if the user is assigned the role with one of the
        # role titles given as parameters. False otherwise.
        def has_role?(*roles_identifiers)
          roles.any? { |role| roles_identifiers.include?(role.identifier) }
        end
      end
    end # :roles

    if not klass.reflect_on_association(:roles).nil? and not klass.reflect_on_association(:roles).klass.reflect_on_association(:static_permissions).nil? then
      RAILS_DEFAULT_LOGGER.debug "Extending class '#{klass}' with static_permissions and has_static_permission?."
      
      klass.class_eval do
        # This method returns a list of all the StaticPermission entities that
        # have been assigned to this user through his roles.
        def static_permissions
          permissions = Array.new

          roles.each do |role|
            permissions.concat(role.static_permissions)
          end

          return permissions
        end

        # This method returns true if the user is granted the permission with one
        # of the given permission titles.
        def has_static_permission?(*permissions_identifiers)
          static_permissions.any? { |permission| permissions_identifiers.include?(permission.identifier) }
        end
      end
    end # :static_permissions
  end
  
  # Module with the method defining behaviour that does not depend on other classes.
  module IndependentBehaviour
    # Return false: ActiveRecord User instances never represent anonymous
    # users.
    def is_anonymous?; false; end
  end
end