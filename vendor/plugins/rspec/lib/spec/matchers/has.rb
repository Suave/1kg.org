module Spec
  module Matchers
    
    class Has #:nodoc:
      def initialize(sym, *args)
        @sym = sym
        @args = args
      end
      
<<<<<<< HEAD:vendor/plugins/rspec/lib/spec/matchers/has.rb
      def matches?(given)
        given.__send__(predicate, *@args)
=======
      def matches?(target)
        target.__send__(predicate, *@args)
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/lib/spec/matchers/has.rb
      end
      
      def failure_message
        "expected ##{predicate}(#{@args[0].inspect}) to return true, got false"
      end
      
      def negative_failure_message
        "expected ##{predicate}(#{@args[0].inspect}) to return false, got true"
      end
      
      def description
        "have key #{@args[0].inspect}"
      end
      
      private
        def predicate
          "#{@sym.to_s.sub("have_","has_")}?".to_sym
        end
        
    end
 
  end
end
