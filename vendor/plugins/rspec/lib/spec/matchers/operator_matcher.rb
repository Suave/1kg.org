module Spec
  module Matchers
    class BaseOperatorMatcher
      attr_reader :generated_description
      
<<<<<<< HEAD:vendor/plugins/rspec/lib/spec/matchers/operator_matcher.rb
<<<<<<< HEAD:vendor/plugins/rspec/lib/spec/matchers/operator_matcher.rb
      def initialize(given)
        @given = given
=======
      def initialize(target)
        @target = target
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/lib/spec/matchers/operator_matcher.rb
=======
      def initialize(target)
        @target = target
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/lib/spec/matchers/operator_matcher.rb
      end

      def ==(expected)
        @expected = expected
<<<<<<< HEAD:vendor/plugins/rspec/lib/spec/matchers/operator_matcher.rb
<<<<<<< HEAD:vendor/plugins/rspec/lib/spec/matchers/operator_matcher.rb
        __delegate_method_missing_to_given("==", expected)
=======
        __delegate_method_missing_to_target("==", expected)
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/lib/spec/matchers/operator_matcher.rb
=======
        __delegate_method_missing_to_target("==", expected)
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/lib/spec/matchers/operator_matcher.rb
      end

      def ===(expected)
        @expected = expected
<<<<<<< HEAD:vendor/plugins/rspec/lib/spec/matchers/operator_matcher.rb
<<<<<<< HEAD:vendor/plugins/rspec/lib/spec/matchers/operator_matcher.rb
        __delegate_method_missing_to_given("===", expected)
=======
        __delegate_method_missing_to_target("===", expected)
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/lib/spec/matchers/operator_matcher.rb
=======
        __delegate_method_missing_to_target("===", expected)
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/lib/spec/matchers/operator_matcher.rb
      end

      def =~(expected)
        @expected = expected
<<<<<<< HEAD:vendor/plugins/rspec/lib/spec/matchers/operator_matcher.rb
<<<<<<< HEAD:vendor/plugins/rspec/lib/spec/matchers/operator_matcher.rb
        __delegate_method_missing_to_given("=~", expected)
=======
        __delegate_method_missing_to_target("=~", expected)
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/lib/spec/matchers/operator_matcher.rb
=======
        __delegate_method_missing_to_target("=~", expected)
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/lib/spec/matchers/operator_matcher.rb
      end

      def >(expected)
        @expected = expected
<<<<<<< HEAD:vendor/plugins/rspec/lib/spec/matchers/operator_matcher.rb
<<<<<<< HEAD:vendor/plugins/rspec/lib/spec/matchers/operator_matcher.rb
        __delegate_method_missing_to_given(">", expected)
=======
        __delegate_method_missing_to_target(">", expected)
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/lib/spec/matchers/operator_matcher.rb
=======
        __delegate_method_missing_to_target(">", expected)
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/lib/spec/matchers/operator_matcher.rb
      end

      def >=(expected)
        @expected = expected
<<<<<<< HEAD:vendor/plugins/rspec/lib/spec/matchers/operator_matcher.rb
<<<<<<< HEAD:vendor/plugins/rspec/lib/spec/matchers/operator_matcher.rb
        __delegate_method_missing_to_given(">=", expected)
=======
        __delegate_method_missing_to_target(">=", expected)
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/lib/spec/matchers/operator_matcher.rb
=======
        __delegate_method_missing_to_target(">=", expected)
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/lib/spec/matchers/operator_matcher.rb
      end

      def <(expected)
        @expected = expected
<<<<<<< HEAD:vendor/plugins/rspec/lib/spec/matchers/operator_matcher.rb
<<<<<<< HEAD:vendor/plugins/rspec/lib/spec/matchers/operator_matcher.rb
        __delegate_method_missing_to_given("<", expected)
=======
        __delegate_method_missing_to_target("<", expected)
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/lib/spec/matchers/operator_matcher.rb
=======
        __delegate_method_missing_to_target("<", expected)
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/lib/spec/matchers/operator_matcher.rb
      end

      def <=(expected)
        @expected = expected
<<<<<<< HEAD:vendor/plugins/rspec/lib/spec/matchers/operator_matcher.rb
<<<<<<< HEAD:vendor/plugins/rspec/lib/spec/matchers/operator_matcher.rb
        __delegate_method_missing_to_given("<=", expected)
      end

      def fail_with_message(message)
        Spec::Expectations.fail_with(message, @expected, @given)
=======
=======
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/lib/spec/matchers/operator_matcher.rb
        __delegate_method_missing_to_target("<=", expected)
      end

      def fail_with_message(message)
        Spec::Expectations.fail_with(message, @expected, @target)
<<<<<<< HEAD:vendor/plugins/rspec/lib/spec/matchers/operator_matcher.rb
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/lib/spec/matchers/operator_matcher.rb
=======
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/lib/spec/matchers/operator_matcher.rb
      end
      
      def description
        "#{@operator} #{@expected.inspect}"
      end

    end

    class PositiveOperatorMatcher < BaseOperatorMatcher #:nodoc:

<<<<<<< HEAD:vendor/plugins/rspec/lib/spec/matchers/operator_matcher.rb
<<<<<<< HEAD:vendor/plugins/rspec/lib/spec/matchers/operator_matcher.rb
      def __delegate_method_missing_to_given(operator, expected)
        @operator = operator
        ::Spec::Matchers.last_matcher = self
        return true if @given.__send__(operator, expected)
        return fail_with_message("expected: #{expected.inspect},\n     got: #{@given.inspect} (using #{operator})") if ['==','===', '=~'].include?(operator)
        return fail_with_message("expected: #{operator} #{expected.inspect},\n     got: #{operator.gsub(/./, ' ')} #{@given.inspect}")
=======
=======
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/lib/spec/matchers/operator_matcher.rb
      def __delegate_method_missing_to_target(operator, expected)
        @operator = operator
        ::Spec::Matchers.last_matcher = self
        return true if @target.__send__(operator, expected)
        return fail_with_message("expected: #{expected.inspect},\n     got: #{@target.inspect} (using #{operator})") if ['==','===', '=~'].include?(operator)
        return fail_with_message("expected: #{operator} #{expected.inspect},\n     got: #{operator.gsub(/./, ' ')} #{@target.inspect}")
<<<<<<< HEAD:vendor/plugins/rspec/lib/spec/matchers/operator_matcher.rb
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/lib/spec/matchers/operator_matcher.rb
=======
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/lib/spec/matchers/operator_matcher.rb
      end

    end

    class NegativeOperatorMatcher < BaseOperatorMatcher #:nodoc:

<<<<<<< HEAD:vendor/plugins/rspec/lib/spec/matchers/operator_matcher.rb
<<<<<<< HEAD:vendor/plugins/rspec/lib/spec/matchers/operator_matcher.rb
      def __delegate_method_missing_to_given(operator, expected)
        @operator = operator
        ::Spec::Matchers.last_matcher = self
        return true unless @given.__send__(operator, expected)
        return fail_with_message("expected not: #{operator} #{expected.inspect},\n         got: #{operator.gsub(/./, ' ')} #{@given.inspect}")
=======
=======
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/lib/spec/matchers/operator_matcher.rb
      def __delegate_method_missing_to_target(operator, expected)
        @operator = operator
        ::Spec::Matchers.last_matcher = self
        return true unless @target.__send__(operator, expected)
        return fail_with_message("expected not: #{operator} #{expected.inspect},\n         got: #{operator.gsub(/./, ' ')} #{@target.inspect}")
<<<<<<< HEAD:vendor/plugins/rspec/lib/spec/matchers/operator_matcher.rb
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/lib/spec/matchers/operator_matcher.rb
=======
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/lib/spec/matchers/operator_matcher.rb
      end

    end

  end
end
