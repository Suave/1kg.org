module Spec
  module Matchers
  
    class Eql #:nodoc:
      def initialize(expected)
        @expected = expected
      end
  
<<<<<<< HEAD:vendor/plugins/rspec/lib/spec/matchers/eql.rb
<<<<<<< HEAD:vendor/plugins/rspec/lib/spec/matchers/eql.rb
      def matches?(given)
        @given = given
        @given.eql?(@expected)
      end

      def failure_message
        return "expected #{@expected.inspect}, got #{@given.inspect} (using .eql?)", @expected, @given
      end
      
      def negative_failure_message
        return "expected #{@given.inspect} not to equal #{@expected.inspect} (using .eql?)", @expected, @given
=======
=======
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/lib/spec/matchers/eql.rb
      def matches?(actual)
        @actual = actual
        @actual.eql?(@expected)
      end

      def failure_message
        return "expected #{@expected.inspect}, got #{@actual.inspect} (using .eql?)", @expected, @actual
      end
      
      def negative_failure_message
        return "expected #{@actual.inspect} not to equal #{@expected.inspect} (using .eql?)", @expected, @actual
<<<<<<< HEAD:vendor/plugins/rspec/lib/spec/matchers/eql.rb
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/lib/spec/matchers/eql.rb
=======
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/lib/spec/matchers/eql.rb
      end

      def description
        "eql #{@expected.inspect}"
      end
    end
    
    # :call-seq:
    #   should eql(expected)
    #   should_not eql(expected)
    #
<<<<<<< HEAD:vendor/plugins/rspec/lib/spec/matchers/eql.rb
<<<<<<< HEAD:vendor/plugins/rspec/lib/spec/matchers/eql.rb
    # Passes if given and expected are of equal value, but not necessarily the same object.
=======
    # Passes if actual and expected are of equal value, but not necessarily the same object.
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/lib/spec/matchers/eql.rb
=======
    # Passes if actual and expected are of equal value, but not necessarily the same object.
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/lib/spec/matchers/eql.rb
    #
    # See http://www.ruby-doc.org/core/classes/Object.html#M001057 for more information about equality in Ruby.
    #
    # == Examples
    #
    #   5.should eql(5)
    #   5.should_not eql(3)
    def eql(expected)
      Matchers::Eql.new(expected)
    end
  end
end
