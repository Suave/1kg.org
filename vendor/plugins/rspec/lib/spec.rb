require 'spec/matchers'
require 'spec/expectations'
require 'spec/example'
require 'spec/extensions'
require 'spec/runner'
require 'spec/adapters'
require 'spec/version'

if Object.const_defined?(:Test)
  require 'spec/interop/test'
end

module Spec
  class << self
    def run?
      Runner.options.examples_run?
    end

    def run
      return true if run?
      Runner.options.run_examples
    end
    
    def exit?
      !Object.const_defined?(:Test) || Test::Unit.run?
    end
<<<<<<< HEAD:vendor/plugins/rspec/lib/spec.rb

    def spec_command?
      $0.split('/').last == 'spec'
    end
  end
end
=======
  end
end
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/lib/spec.rb
