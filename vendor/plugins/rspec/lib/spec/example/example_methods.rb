module Spec
  module Example
    module ExampleMethods
      extend ExampleGroupMethods
      extend ModuleReopeningFix
      include ModuleInclusionWarnings
      
<<<<<<< HEAD:vendor/plugins/rspec/lib/spec/example/example_methods.rb
<<<<<<< HEAD:vendor/plugins/rspec/lib/spec/example/example_methods.rb
=======
=======
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/lib/spec/example/example_methods.rb

      PENDING_EXAMPLE_BLOCK = lambda {
        raise Spec::Example::ExamplePendingError.new("Not Yet Implemented")
      }

<<<<<<< HEAD:vendor/plugins/rspec/lib/spec/example/example_methods.rb
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/lib/spec/example/example_methods.rb
=======
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/lib/spec/example/example_methods.rb
      def execute(options, instance_variables)
        options.reporter.example_started(self)
        set_instance_variables_from_hash(instance_variables)
        
        execution_error = nil
        Timeout.timeout(options.timeout) do
          begin
            before_example
            eval_block
          rescue Exception => e
            execution_error ||= e
          end
          begin
            after_example
          rescue Exception => e
            execution_error ||= e
          end
        end

        options.reporter.example_finished(self, execution_error)
        success = execution_error.nil? || ExamplePendingError === execution_error
      end

      def instance_variable_hash
        instance_variables.inject({}) do |variable_hash, variable_name|
          variable_hash[variable_name] = instance_variable_get(variable_name)
          variable_hash
        end
      end

      def violated(message="")
        raise Spec::Expectations::ExpectationNotMetError.new(message)
      end

      def eval_each_fail_fast(procs) #:nodoc:
        procs.each do |proc|
          instance_eval(&proc)
        end
      end

      def eval_each_fail_slow(procs) #:nodoc:
        first_exception = nil
        procs.each do |proc|
          begin
            instance_eval(&proc)
          rescue Exception => e
            first_exception ||= e
          end
        end
        raise first_exception if first_exception
      end

      def description
        @_defined_description || ::Spec::Matchers.generated_description || "NO NAME"
      end
<<<<<<< HEAD:vendor/plugins/rspec/lib/spec/example/example_methods.rb
<<<<<<< HEAD:vendor/plugins/rspec/lib/spec/example/example_methods.rb
      
      def options
        @_options
      end
=======
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/lib/spec/example/example_methods.rb
=======
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/lib/spec/example/example_methods.rb

      def __full_description
        "#{self.class.description} #{self.description}"
      end
      
      def set_instance_variables_from_hash(ivars)
        ivars.each do |variable_name, value|
          # Ruby 1.9 requires variable.to_s on the next line
          unless ['@_implementation', '@_defined_description', '@_matcher_description', '@method_name'].include?(variable_name.to_s)
            instance_variable_set variable_name, value
          end
        end
      end

      def eval_block
<<<<<<< HEAD:vendor/plugins/rspec/lib/spec/example/example_methods.rb
<<<<<<< HEAD:vendor/plugins/rspec/lib/spec/example/example_methods.rb
        instance_eval(&@_implementation)
=======
        return instance_eval(&(@_implementation || PENDING_EXAMPLE_BLOCK))
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/lib/spec/example/example_methods.rb
=======
        return instance_eval(&(@_implementation || PENDING_EXAMPLE_BLOCK))
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/lib/spec/example/example_methods.rb
      end

      def implementation_backtrace
        eval("caller", @_implementation)
      end
      
      protected
      include Matchers
      include Pending
      
      def before_example
        setup_mocks_for_rspec
        self.class.run_before_each(self)
      end

      def after_example
        self.class.run_after_each(self)
        verify_mocks_for_rspec
      ensure
        teardown_mocks_for_rspec
      end
    end
  end
<<<<<<< HEAD:vendor/plugins/rspec/lib/spec/example/example_methods.rb
<<<<<<< HEAD:vendor/plugins/rspec/lib/spec/example/example_methods.rb
end
=======
end
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/lib/spec/example/example_methods.rb
=======
end
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/lib/spec/example/example_methods.rb
