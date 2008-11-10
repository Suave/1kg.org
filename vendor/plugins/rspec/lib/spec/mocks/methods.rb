module Spec
  module Mocks
    module Methods
      def should_receive(sym, opts={}, &block)
        __mock_proxy.add_message_expectation(opts[:expected_from] || caller(1)[0], sym.to_sym, opts, &block)
      end

      def should_not_receive(sym, &block)
        __mock_proxy.add_negative_message_expectation(caller(1)[0], sym.to_sym, &block)
      end
      
      def stub!(sym_or_hash, opts={})
        if Hash === sym_or_hash
          sym_or_hash.each {|method, value| stub!(method).and_return value }
        else
          __mock_proxy.add_stub(caller(1)[0], sym_or_hash.to_sym, opts)
        end
      end
      
      def received_message?(sym, *args, &block) #:nodoc:
        __mock_proxy.received_message?(sym.to_sym, *args, &block)
      end
      
      def rspec_verify #:nodoc:
        __mock_proxy.verify
      end

      def rspec_reset #:nodoc:
        __mock_proxy.reset
      end
      
      def as_null_object
<<<<<<< HEAD:vendor/plugins/rspec/lib/spec/mocks/methods.rb
        __mock_proxy.as_null_object
=======
        __mock_proxy.act_as_null_object
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/lib/spec/mocks/methods.rb
      end
      
      def null_object?
        __mock_proxy.null_object?
      end

    private

      def __mock_proxy
        if Mock === self
          @mock_proxy ||= Proxy.new(self, @name, @options)
        else
<<<<<<< HEAD:vendor/plugins/rspec/lib/spec/mocks/methods.rb
          @mock_proxy ||= Proxy.new(self)
=======
          @mock_proxy ||= Proxy.new(self, self.class.name)
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/lib/spec/mocks/methods.rb
        end
      end
    end
  end
end
