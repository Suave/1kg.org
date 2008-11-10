module Spec
  module Matchers
    class RaiseError #:nodoc:
<<<<<<< HEAD:vendor/plugins/rspec/lib/spec/matchers/raise_error.rb
      def initialize(expected_error_or_message=Exception, expected_message=nil, &block)
        @block = block
        case expected_error_or_message
        when String, Regexp
          @expected_error, @expected_message = Exception, expected_error_or_message
        else
          @expected_error, @expected_message = expected_error_or_message, expected_message
        end
      end

      def matches?(given_proc)
=======
      def initialize(error_or_message=Exception, message=nil, &block)
        @block = block
        case error_or_message
        when String, Regexp
          @expected_error, @expected_message = Exception, error_or_message
        else
          @expected_error, @expected_message = error_or_message, message
        end
      end

      def matches?(proc)
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/lib/spec/matchers/raise_error.rb
        @raised_expected_error = false
        @with_expected_message = false
        @eval_block = false
        @eval_block_passed = false
        begin
<<<<<<< HEAD:vendor/plugins/rspec/lib/spec/matchers/raise_error.rb
          given_proc.call
        rescue @expected_error => @given_error
          @raised_expected_error = true
          @with_expected_message = verify_message
        rescue Exception => @given_error
=======
          proc.call
        rescue @expected_error => @actual_error
          @raised_expected_error = true
          @with_expected_message = verify_message
        rescue Exception => @actual_error
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/lib/spec/matchers/raise_error.rb
          # This clause should be empty, but rcov will not report it as covered
          # unless something (anything) is executed within the clause
          rcov_error_report = "http://eigenclass.org/hiki.rb?rcov-0.8.0"
        end

        unless negative_expectation?
          eval_block if @raised_expected_error && @with_expected_message && @block
        end
      ensure
        return (@raised_expected_error && @with_expected_message) ? (@eval_block ? @eval_block_passed : true) : false
      end
      
      def eval_block
        @eval_block = true
        begin
<<<<<<< HEAD:vendor/plugins/rspec/lib/spec/matchers/raise_error.rb
          @block[@given_error]
          @eval_block_passed = true
        rescue Exception => err
          @given_error = err
=======
          @block[@actual_error]
          @eval_block_passed = true
        rescue Exception => err
          @actual_error = err
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/lib/spec/matchers/raise_error.rb
        end
      end

      def verify_message
        case @expected_message
        when nil
          return true
        when Regexp
<<<<<<< HEAD:vendor/plugins/rspec/lib/spec/matchers/raise_error.rb
          return @expected_message =~ @given_error.message
        else
          return @expected_message == @given_error.message
=======
          return @expected_message =~ @actual_error.message
        else
          return @expected_message == @actual_error.message
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/lib/spec/matchers/raise_error.rb
        end
      end
      
      def failure_message
        if @eval_block
<<<<<<< HEAD:vendor/plugins/rspec/lib/spec/matchers/raise_error.rb
          return @given_error.message
        else
          return "expected #{expected_error}#{given_error}"
=======
          return @actual_error.message
        else
          return "expected #{expected_error}#{actual_error}"
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/lib/spec/matchers/raise_error.rb
        end
      end

      def negative_failure_message
<<<<<<< HEAD:vendor/plugins/rspec/lib/spec/matchers/raise_error.rb
        "expected no #{expected_error}#{given_error}"
=======
        "expected no #{expected_error}#{actual_error}"
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/lib/spec/matchers/raise_error.rb
      end
      
      def description
        "raise #{expected_error}"
      end
      
      private
        def expected_error
          case @expected_message
          when nil
            @expected_error
          when Regexp
            "#{@expected_error} with message matching #{@expected_message.inspect}"
          else
            "#{@expected_error} with #{@expected_message.inspect}"
          end
        end

<<<<<<< HEAD:vendor/plugins/rspec/lib/spec/matchers/raise_error.rb
        def given_error
          @given_error.nil? ? " but nothing was raised" : ", got #{@given_error.inspect}"
=======
        def actual_error
          @actual_error.nil? ? " but nothing was raised" : ", got #{@actual_error.inspect}"
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/lib/spec/matchers/raise_error.rb
        end
        
        def negative_expectation?
          # YES - I'm a bad person... help me find a better way - ryand
          caller.first(3).find { |s| s =~ /should_not/ }
        end
    end
    
    # :call-seq:
    #   should raise_error()
    #   should raise_error(NamedError)
    #   should raise_error(NamedError, String)
    #   should raise_error(NamedError, Regexp)
    #   should raise_error() { |error| ... }
    #   should raise_error(NamedError) { |error| ... }
    #   should raise_error(NamedError, String) { |error| ... }
    #   should raise_error(NamedError, Regexp) { |error| ... }
    #   should_not raise_error()
    #   should_not raise_error(NamedError)
    #   should_not raise_error(NamedError, String)
    #   should_not raise_error(NamedError, Regexp)
    #
    # With no args, matches if any error is raised.
    # With a named error, matches only if that specific error is raised.
    # With a named error and messsage specified as a String, matches only if both match.
    # With a named error and messsage specified as a Regexp, matches only if both match.
    # Pass an optional block to perform extra verifications on the exception matched
    #
    # == Examples
    #
    #   lambda { do_something_risky }.should raise_error
    #   lambda { do_something_risky }.should raise_error(PoorRiskDecisionError)
    #   lambda { do_something_risky }.should raise_error(PoorRiskDecisionError) { |error| error.data.should == 42 }
    #   lambda { do_something_risky }.should raise_error(PoorRiskDecisionError, "that was too risky")
    #   lambda { do_something_risky }.should raise_error(PoorRiskDecisionError, /oo ri/)
    #
    #   lambda { do_something_risky }.should_not raise_error
    #   lambda { do_something_risky }.should_not raise_error(PoorRiskDecisionError)
    #   lambda { do_something_risky }.should_not raise_error(PoorRiskDecisionError, "that was too risky")
    #   lambda { do_something_risky }.should_not raise_error(PoorRiskDecisionError, /oo ri/)
    def raise_error(error=Exception, message=nil, &block)
      Matchers::RaiseError.new(error, message, &block)
    end
  end
end
