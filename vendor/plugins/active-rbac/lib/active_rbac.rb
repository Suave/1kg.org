#--
# Project:   active_rbac 
# File:      lib/active_rbac.rb
# Author:    Manuel Holtgrewe <purestorm at ggnore dot net>
# Copyright: (c) 2005 by Manuel Holtgrewe
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

# Make ActiveRecord::Base respond to acts_as_encrypts_password.
require 'active_rbac/acts_as_encrypts_password'
ActiveRecord::Base.send :extend, ActsAsEncryptsPassword::ActsAsMethods

# Make ActionController::Base respond to current_user and current_user=.
require 'active_rbac/acts_as_current_user_container'
ActionController::Base.send :extend, ActsAsCurrentUserContainer::ActsAsMethods

# Make Object respond to acts_as_anonymous_user to classes can be marked to be
# anonymous user objects.
require 'active_rbac/acts_as_anonymous_user'
Object.send :extend, ActsAsAnonymousUser::ActsAsMethods

# Get the ActiveRbac::ModelRegistry singleton class.
require 'active_rbac/model_registry'

# Make ActiveRecord::Base respond to acts_as_user, acts_as_role and 
# acts_as_static_permission.
require 'active_rbac/acts_as_user'
ActiveRecord::Base.send :extend, ActsAsUser::ActsAsMethods
require 'active_rbac/acts_as_role'
ActiveRecord::Base.send :extend, ActsAsRole::ActsAsMethods
require 'active_rbac/acts_as_static_permission'
ActiveRecord::Base.send :extend, ActsAsStaticPermission::ActsAsMethods
