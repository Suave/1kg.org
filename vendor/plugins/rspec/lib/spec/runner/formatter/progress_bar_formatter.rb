require 'spec/runner/formatter/base_text_formatter'

module Spec
  module Runner
    module Formatter
      class ProgressBarFormatter < BaseTextFormatter
        def example_failed(example, counter, failure)
          @output.print colourise('F', failure)
          @output.flush
        end

        def example_passed(example)
          @output.print green('.')
          @output.flush
        end
      
<<<<<<< HEAD:vendor/plugins/rspec/lib/spec/runner/formatter/progress_bar_formatter.rb
        def example_pending(example, message, pending_caller)
          super
          @output.print yellow('*')
=======
        def example_pending(example, message)
          super
          @output.print yellow('P')
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/lib/spec/runner/formatter/progress_bar_formatter.rb
          @output.flush
        end
        
        def start_dump
          @output.puts
          @output.flush
        end
        
        def method_missing(sym, *args)
          # ignore
        end
      end
    end
  end
end
