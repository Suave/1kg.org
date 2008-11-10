module Spec
  module Mocks
    class Proxy
      DEFAULT_OPTIONS = {
        :null_object => false,
      }
<<<<<<< HEAD:vendor/plugins/rspec/lib/spec/mocks/proxy.rb
      
      @@warn_about_expectations_on_nil = true
      
      def self.allow_message_expectations_on_nil
        @@warn_about_expectations_on_nil = false
        
        # ensure nil.rspec_verify is called even if an expectation is not set in the example
        # otherwise the allowance would effect subsequent examples
        $rspec_mocks.add(nil) unless $rspec_mocks.nil?
      end

      def initialize(target, name=nil, options={})
=======

      def initialize(target, name, options={})
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/lib/spec/mocks/proxy.rb
        @target = target
        @name = name
        @error_generator = ErrorGenerator.new target, name
        @expectation_ordering = OrderGroup.new @error_generator
        @expectations = []
        @messages_received = []
        @stubs = []
        @proxied_methods = []
        @options = options ? DEFAULT_OPTIONS.dup.merge(options) : DEFAULT_OPTIONS
      end

      def null_object?
        @options[:null_object]
      end
      
<<<<<<< HEAD:vendor/plugins/rspec/lib/spec/mocks/proxy.rb
      def as_null_object
=======
      def act_as_null_object
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/lib/spec/mocks/proxy.rb
        @options[:null_object] = true
        @target
      end

<<<<<<< HEAD:vendor/plugins/rspec/lib/spec/mocks/proxy.rb
      def add_message_expectation(expected_from, sym, opts={}, &block)        
        __add sym
        warn_if_nil_class sym
        if existing_stub = @stubs.detect {|s| s.sym == sym }
          expectation = existing_stub.build_child(expected_from, block_given?? block : nil, 1, opts)
        else
          expectation = MessageExpectation.new(@error_generator, @expectation_ordering, expected_from, sym, block_given? ? block : nil, 1, opts)
        end
        @expectations << expectation
=======
      def add_message_expectation(expected_from, sym, opts={}, &block)
        __add sym
        @expectations << MessageExpectation.new(@error_generator, @expectation_ordering, expected_from, sym, block_given? ? block : nil, 1, opts)
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/lib/spec/mocks/proxy.rb
        @expectations.last
      end

      def add_negative_message_expectation(expected_from, sym, &block)
        __add sym
<<<<<<< HEAD:vendor/plugins/rspec/lib/spec/mocks/proxy.rb
        warn_if_nil_class sym
=======
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/lib/spec/mocks/proxy.rb
        @expectations << NegativeMessageExpectation.new(@error_generator, @expectation_ordering, expected_from, sym, block_given? ? block : nil)
        @expectations.last
      end

      def add_stub(expected_from, sym, opts={})
        __add sym
        @stubs.unshift MessageExpectation.new(@error_generator, @expectation_ordering, expected_from, sym, nil, :any, opts)
        @stubs.first
      end

      def verify #:nodoc:
        verify_expectations
      ensure
        reset
      end

      def reset
        clear_expectations
        clear_stubs
        reset_proxied_methods
        clear_proxied_methods
<<<<<<< HEAD:vendor/plugins/rspec/lib/spec/mocks/proxy.rb
        reset_nil_expectations_warning
=======
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/lib/spec/mocks/proxy.rb
      end

      def received_message?(sym, *args, &block)
        @messages_received.any? {|array| array == [sym, args, block]}
      end

      def has_negative_expectation?(sym)
        @expectations.detect {|expectation| expectation.negative_expectation_for?(sym)}
      end

      def message_received(sym, *args, &block)
<<<<<<< HEAD:vendor/plugins/rspec/lib/spec/mocks/proxy.rb
        expectation = find_matching_expectation(sym, *args)
        stub = find_matching_method_stub(sym, *args)

        if (stub && expectation && expectation.called_max_times?) || (stub && !expectation)
=======
        if expectation = find_matching_expectation(sym, *args)
          expectation.invoke(args, block)
        elsif (stub = find_matching_method_stub(sym, *args))
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/lib/spec/mocks/proxy.rb
          if expectation = find_almost_matching_expectation(sym, *args)
            expectation.advise(args, block) unless expectation.expected_messages_received?
          end
          stub.invoke([], block)
<<<<<<< HEAD:vendor/plugins/rspec/lib/spec/mocks/proxy.rb
        elsif expectation
          expectation.invoke(args, block)
=======
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/lib/spec/mocks/proxy.rb
        elsif expectation = find_almost_matching_expectation(sym, *args)
          expectation.advise(args, block) if null_object? unless expectation.expected_messages_received?
          raise_unexpected_message_args_error(expectation, *args) unless (has_negative_expectation?(sym) or null_object?)
        else
          @target.send :method_missing, sym, *args, &block
        end
      end

      def raise_unexpected_message_args_error(expectation, *args)
        @error_generator.raise_unexpected_message_args_error expectation, *args
      end

      def raise_unexpected_message_error(sym, *args)
        @error_generator.raise_unexpected_message_error sym, *args
      end
      
    private

      def __add(sym)
        $rspec_mocks.add(@target) unless $rspec_mocks.nil?
        define_expected_method(sym)
      end
      
<<<<<<< HEAD:vendor/plugins/rspec/lib/spec/mocks/proxy.rb
      def warn_if_nil_class(sym)
        if proxy_for_nil_class? && @@warn_about_expectations_on_nil          
          Kernel.warn("An expectation of :#{sym} was set on nil. Called from #{caller[2]}. Use allow_message_expectations_on_nil to disable warnings.")
        end
      end
      
=======
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/lib/spec/mocks/proxy.rb
      def define_expected_method(sym)
        visibility_string = "#{visibility(sym)} :#{sym}"
        if target_responds_to?(sym) && !target_metaclass.method_defined?(munge(sym))
          munged_sym = munge(sym)
          target_metaclass.instance_eval do
            alias_method munged_sym, sym if method_defined?(sym.to_s)
          end
          @proxied_methods << sym
        end
        
        target_metaclass.class_eval(<<-EOF, __FILE__, __LINE__)
          def #{sym}(*args, &block)
            __mock_proxy.message_received :#{sym}, *args, &block
          end
          #{visibility_string}
        EOF
      end

      def target_responds_to?(sym)
        return @target.send(munge(:respond_to?),sym) if @already_proxied_respond_to
        return @already_proxied_respond_to = true if sym == :respond_to?
        return @target.respond_to?(sym)
      end

      def visibility(sym)
        if Mock === @target
          'public'
        elsif target_metaclass.private_method_defined?(sym)
          'private'
        elsif target_metaclass.protected_method_defined?(sym)
          'protected'
        else
          'public'
        end
      end

      def munge(sym)
        "proxied_by_rspec__#{sym.to_s}".to_sym
      end

      def clear_expectations
        @expectations.clear
      end

      def clear_stubs
        @stubs.clear
      end

      def clear_proxied_methods
        @proxied_methods.clear
      end

      def target_metaclass
        class << @target; self; end
      end

      def verify_expectations
        @expectations.each do |expectation|
          expectation.verify_messages_received
        end
      end

      def reset_proxied_methods
        @proxied_methods.each do |sym|
          munged_sym = munge(sym)
          target_metaclass.instance_eval do
            if method_defined?(munged_sym.to_s)
              alias_method sym, munged_sym
              undef_method munged_sym
            else
              undef_method sym
            end
          end
        end
      end
<<<<<<< HEAD:vendor/plugins/rspec/lib/spec/mocks/proxy.rb
      
      def proxy_for_nil_class?
        @target.nil?
      end
      
      def reset_nil_expectations_warning
        @@warn_about_expectations_on_nil = true if proxy_for_nil_class?
      end
=======
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/lib/spec/mocks/proxy.rb

      def find_matching_expectation(sym, *args)
        @expectations.find {|expectation| expectation.matches(sym, args)}
      end

      def find_almost_matching_expectation(sym, *args)
        @expectations.find {|expectation| expectation.matches_name_but_not_args(sym, args)}
      end

      def find_matching_method_stub(sym, *args)
        @stubs.find {|stub| stub.matches(sym, args)}
      end

    end
  end
end
