require 'spec/runner/formatter/base_text_formatter'

module Spec
  module Runner
    module Formatter
      class SpecdocFormatter < BaseTextFormatter
        def add_example_group(example_group)
          super
          output.puts
          output.puts example_group.description
          output.flush
        end
      
        def example_failed(example, counter, failure)
          message = if failure.expectation_not_met?
            "- #{example.description} (FAILED - #{counter})"
          else
            "- #{example.description} (ERROR - #{counter})"
          end
          
          output.puts(failure.expectation_not_met? ? red(message) : magenta(message))
          output.flush
        end
        
        def example_passed(example)
          message = "- #{example.description}"
          output.puts green(message)
          output.flush
        end
        
<<<<<<< HEAD:vendor/plugins/rspec/lib/spec/runner/formatter/specdoc_formatter.rb
<<<<<<< HEAD:vendor/plugins/rspec/lib/spec/runner/formatter/specdoc_formatter.rb
        def example_pending(example, message, pending_caller)
=======
        def example_pending(example, message)
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/lib/spec/runner/formatter/specdoc_formatter.rb
=======
        def example_pending(example, message)
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/lib/spec/runner/formatter/specdoc_formatter.rb
          super
          output.puts yellow("- #{example.description} (PENDING: #{message})")
          output.flush
        end
      end
    end
  end
end
