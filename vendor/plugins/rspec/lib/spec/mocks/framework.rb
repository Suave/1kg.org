# Require everything except the global extensions of class and object. This
# supports wrapping rspec's mocking functionality without invading every
# object in the system.

require 'spec/mocks/methods'
<<<<<<< HEAD:vendor/plugins/rspec/lib/spec/mocks/framework.rb
require 'spec/mocks/argument_constraints'
=======
require 'spec/mocks/argument_constraint_matchers'
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/lib/spec/mocks/framework.rb
require 'spec/mocks/spec_methods'
require 'spec/mocks/proxy'
require 'spec/mocks/mock'
require 'spec/mocks/argument_expectation'
require 'spec/mocks/message_expectation'
require 'spec/mocks/order_group'
require 'spec/mocks/errors'
require 'spec/mocks/error_generator'
require 'spec/mocks/space'
