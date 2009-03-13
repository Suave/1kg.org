module Spec
  module Example
    # Base class for customized example groups. Use this if you
    # want to make a custom example group.
    class ExampleGroup
      extend Spec::Example::ExampleGroupMethods
      include Spec::Example::ExampleMethods

<<<<<<< HEAD:vendor/plugins/rspec/lib/spec/example/example_group.rb
      def initialize(defined_description, options={}, &implementation)
        @_options = options
        @_defined_description = defined_description
        @_implementation = implementation || pending_implementation
      end
      
    private
      
      def pending_implementation
        error = NotYetImplementedError.new(caller)
        lambda { raise(error) }
=======
      def initialize(defined_description, &implementation)
        @_defined_description = defined_description
        @_implementation = implementation
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/lib/spec/example/example_group.rb
      end
    end
  end
end

Spec::ExampleGroup = Spec::Example::ExampleGroup
