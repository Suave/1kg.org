module Spec
  module Matchers
    class Exist
<<<<<<< HEAD:vendor/plugins/rspec/lib/spec/matchers/exist.rb
      def matches?(given)
        @given = given
        @given.exist?
      end
      def failure_message
        "expected #{@given.inspect} to exist, but it doesn't."
      end
      def negative_failure_message
        "expected #{@given.inspect} to not exist, but it does."
      end
    end
    # :call-seq:
    #   should exist
    #   should_not exist
    #
    # Passes if given.exist?
=======
      def matches? actual
        @actual = actual
        @actual.exist?
      end
      def failure_message
        "expected #{@actual.inspect} to exist, but it doesn't."
      end
      def negative_failure_message
        "expected #{@actual.inspect} to not exist, but it does."
      end
    end
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/lib/spec/matchers/exist.rb
    def exist; Exist.new; end
  end
end
