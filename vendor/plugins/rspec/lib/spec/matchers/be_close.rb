module Spec
  module Matchers

    class BeClose #:nodoc:
      def initialize(expected, delta)
        @expected = expected
        @delta = delta
      end
      
<<<<<<< HEAD:vendor/plugins/rspec/lib/spec/matchers/be_close.rb
      def matches?(given)
        @given = given
        (@given - @expected).abs < @delta
      end
      
      def failure_message
        "expected #{@expected} +/- (< #{@delta}), got #{@given}"
=======
      def matches?(actual)
        @actual = actual
        (@actual - @expected).abs < @delta
      end
      
      def failure_message
        "expected #{@expected} +/- (< #{@delta}), got #{@actual}"
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/lib/spec/matchers/be_close.rb
      end
      
      def description
        "be close to #{@expected} (within +- #{@delta})"
      end
    end
    
    # :call-seq:
    #   should be_close(expected, delta)
    #   should_not be_close(expected, delta)
    #
<<<<<<< HEAD:vendor/plugins/rspec/lib/spec/matchers/be_close.rb
    # Passes if given == expected +/- delta
=======
    # Passes if actual == expected +/- delta
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/lib/spec/matchers/be_close.rb
    #
    # == Example
    #
    #   result.should be_close(3.0, 0.5)
    def be_close(expected, delta)
      Matchers::BeClose.new(expected, delta)
    end
  end
end
