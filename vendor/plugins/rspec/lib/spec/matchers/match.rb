module Spec
  module Matchers
    
    class Match #:nodoc:
<<<<<<< HEAD:vendor/plugins/rspec/lib/spec/matchers/match.rb
      def initialize(regexp)
        @regexp = regexp
      end
      
      def matches?(given)
        @given = given
        return true if given =~ @regexp
=======
      def initialize(expected)
        @expected = expected
      end
      
      def matches?(actual)
        @actual = actual
        return true if actual =~ @expected
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/lib/spec/matchers/match.rb
        return false
      end
      
      def failure_message
<<<<<<< HEAD:vendor/plugins/rspec/lib/spec/matchers/match.rb
        return "expected #{@given.inspect} to match #{@regexp.inspect}", @regexp, @given
      end
      
      def negative_failure_message
        return "expected #{@given.inspect} not to match #{@regexp.inspect}", @regexp, @given
      end
      
      def description
        "match #{@regexp.inspect}"
=======
        return "expected #{@actual.inspect} to match #{@expected.inspect}", @expected, @actual
      end
      
      def negative_failure_message
        return "expected #{@actual.inspect} not to match #{@expected.inspect}", @expected, @actual
      end
      
      def description
        "match #{@expected.inspect}"
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/lib/spec/matchers/match.rb
      end
    end
    
    # :call-seq:
    #   should match(regexp)
    #   should_not match(regexp)
    #
<<<<<<< HEAD:vendor/plugins/rspec/lib/spec/matchers/match.rb
    # Given a Regexp, passes if given =~ regexp
=======
    # Given a Regexp, passes if actual =~ regexp
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/lib/spec/matchers/match.rb
    #
    # == Examples
    #
    #   email.should match(/^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i)
    def match(regexp)
      Matchers::Match.new(regexp)
    end
  end
end
