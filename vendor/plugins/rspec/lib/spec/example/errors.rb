module Spec
  module Example
    class ExamplePendingError < StandardError
<<<<<<< HEAD:vendor/plugins/rspec/lib/spec/example/errors.rb
      attr_reader :pending_caller

      def initialize(message=nil)
        super
        @pending_caller = caller[2]
      end
    end
    
    class NotYetImplementedError < ExamplePendingError
      MESSAGE = "Not Yet Implemented"
      RSPEC_ROOT_LIB = File.expand_path(File.dirname(__FILE__) + "/../..")
      
      def initialize(backtrace)
        super(MESSAGE)
        @pending_caller = pending_caller_from(backtrace)
      end
      
    private
      
      def pending_caller_from(backtrace)
        backtrace.detect {|line| !line.include?(RSPEC_ROOT_LIB) }
      end
    end

    class PendingExampleFixedError < StandardError; end
=======
    end

    class PendingExampleFixedError < StandardError
    end
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/lib/spec/example/errors.rb
  end
end
