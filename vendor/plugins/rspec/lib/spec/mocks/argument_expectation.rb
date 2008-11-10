module Spec
  module Mocks
<<<<<<< HEAD:vendor/plugins/rspec/lib/spec/mocks/argument_expectation.rb
    
    class ArgumentExpectation
      attr_reader :args
=======
  
    class MatcherConstraint
      def initialize(matcher)
        @matcher = matcher
      end
      
      def matches?(value)
        @matcher.matches?(value)
      end
    end
      
    class LiteralArgConstraint
      def initialize(literal)
        @literal_value = literal
      end
      
      def matches?(value)
        @literal_value == value
      end
    end
    
    class RegexpArgConstraint
      def initialize(regexp)
        @regexp = regexp
      end
      
      def matches?(value)
        return value =~ @regexp unless value.is_a?(Regexp)
        value == @regexp
      end
    end
    
    class AnyArgConstraint
      def initialize(ignore)
      end
      
      def ==(other)
        true
      end
      
      # TODO - need this?
      def matches?(value)
        true
      end
    end
    
    class AnyArgsConstraint
      def description
        "any args"
      end
    end
    
    class NoArgsConstraint
      def description
        "no args"
      end
      
      def ==(args)
        args == []
      end
    end
    
    class NumericArgConstraint
      def initialize(ignore)
      end
      
      def matches?(value)
        value.is_a?(Numeric)
      end
    end
    
    class BooleanArgConstraint
      def initialize(ignore)
      end
      
      def ==(value)
        matches?(value)
      end
      
      def matches?(value)
        return true if value.is_a?(TrueClass)
        return true if value.is_a?(FalseClass)
        false
      end
    end
    
    class StringArgConstraint
      def initialize(ignore)
      end
      
      def matches?(value)
        value.is_a?(String)
      end
    end
    
    class DuckTypeArgConstraint
      def initialize(*methods_to_respond_to)
        @methods_to_respond_to = methods_to_respond_to
      end
  
      def matches?(value)
        @methods_to_respond_to.all? { |sym| value.respond_to?(sym) }
      end
      
      def description
        "duck_type"
      end
    end
    
    class HashIncludingConstraint
      def initialize(expected)
        @expected = expected
      end
      
      def ==(actual)
        @expected.each do | key, value |
          # check key for case that value evaluates to nil
          return false unless actual.has_key?(key) && actual[key] == value
        end
        true
      rescue NoMethodError => ex
        return false
      end
      
      def matches?(value)
        self == value
      end
      
      def description
        "hash_including(#{@expected.inspect.sub(/^\{/,"").sub(/\}$/,"")})"
      end
      
    end
    

    class ArgumentExpectation
      attr_reader :args
      @@constraint_classes = Hash.new { |hash, key| LiteralArgConstraint}
      @@constraint_classes[:anything] = AnyArgConstraint
      @@constraint_classes[:numeric] = NumericArgConstraint
      @@constraint_classes[:boolean] = BooleanArgConstraint
      @@constraint_classes[:string] = StringArgConstraint
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/lib/spec/mocks/argument_expectation.rb
      
      def initialize(args, &block)
        @args = args
        @constraints_block = block
        
<<<<<<< HEAD:vendor/plugins/rspec/lib/spec/mocks/argument_expectation.rb
        if ArgumentConstraints::AnyArgsConstraint === args.first
          @match_any_args = true
        elsif ArgumentConstraints::NoArgsConstraint === args.first
          @constraints = []
        else
          @constraints = args.collect {|arg| constraint_for(arg)}
        end
      end
      
      def constraint_for(arg)
        return ArgumentConstraints::MatcherConstraint.new(arg)   if is_matcher?(arg)
        return ArgumentConstraints::RegexpConstraint.new(arg) if arg.is_a?(Regexp)
        return ArgumentConstraints::EqualityProxy.new(arg)
      end
      
      def is_matcher?(obj)
        return obj.respond_to?(:matches?) && obj.respond_to?(:description)
      end
      
      def args_match?(given_args)
        match_any_args? || constraints_block_matches?(given_args) || constraints_match?(given_args)
      end
      
      def constraints_block_matches?(given_args)
        @constraints_block ? @constraints_block.call(*given_args) : nil
      end
      
      def constraints_match?(given_args)
        @constraints == given_args
      end
      
      def match_any_args?
        @match_any_args
      end
      
=======
        if [:any_args] == args
          @expected_params = nil
          warn_deprecated(:any_args.inspect, "any_args()")
        elsif args.length == 1 && args[0].is_a?(AnyArgsConstraint) then @expected_params = nil
        elsif [:no_args] == args
          @expected_params = []
          warn_deprecated(:no_args.inspect, "no_args()")
        elsif args.length == 1 && args[0].is_a?(NoArgsConstraint) then @expected_params = []
        else @expected_params = process_arg_constraints(args)
        end
      end
      
      def process_arg_constraints(constraints)
        constraints.collect do |constraint| 
          convert_constraint(constraint)
        end
      end
      
      def warn_deprecated(deprecated_method, instead)
        Kernel.warn "The #{deprecated_method} constraint is deprecated. Use #{instead} instead."
      end
      
      def convert_constraint(constraint)
        if [:anything, :numeric, :boolean, :string].include?(constraint)
          case constraint
          when :anything
            instead = "anything()"
          when :boolean
            instead = "boolean()"
          when :numeric
            instead = "an_instance_of(Numeric)"
          when :string
            instead = "an_instance_of(String)"
          end
          warn_deprecated(constraint.inspect, instead)
          return @@constraint_classes[constraint].new(constraint)
        end
        return MatcherConstraint.new(constraint) if is_matcher?(constraint)
        return RegexpArgConstraint.new(constraint) if constraint.is_a?(Regexp)
        return LiteralArgConstraint.new(constraint)
      end
      
      def is_matcher?(obj)
        return obj.respond_to?(:matches?) && obj.respond_to?(:description)
      end
      
      def check_args(args)
        if @constraints_block
          @constraints_block.call(*args)
          return true
        end
        
        return true if @expected_params.nil?
        return true if @expected_params == args
        return constraints_match?(args)
      end
      
      def constraints_match?(args)
        return false if args.length != @expected_params.length
        @expected_params.each_index { |i| return false unless @expected_params[i].matches?(args[i]) }
        return true
      end
  
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/lib/spec/mocks/argument_expectation.rb
    end
    
  end
end
