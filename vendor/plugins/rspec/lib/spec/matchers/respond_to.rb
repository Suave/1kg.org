module Spec
  module Matchers
    
    class RespondTo #:nodoc:
      def initialize(*names)
        @names = names
        @names_not_responded_to = []
      end
      
<<<<<<< HEAD:vendor/plugins/rspec/lib/spec/matchers/respond_to.rb
      def matches?(given)
        @given = given
        @names.each do |name|
          unless given.respond_to?(name)
=======
      def matches?(target)
        @names.each do |name|
          unless target.respond_to?(name)
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/lib/spec/matchers/respond_to.rb
            @names_not_responded_to << name
          end
        end
        return @names_not_responded_to.empty?
      end
      
      def failure_message
<<<<<<< HEAD:vendor/plugins/rspec/lib/spec/matchers/respond_to.rb
        "expected #{@given.inspect} to respond to #{@names_not_responded_to.collect {|name| name.inspect }.join(', ')}"
      end
      
      def negative_failure_message
        "expected #{@given.inspect} not to respond to #{@names.collect {|name| name.inspect }.join(', ')}"
=======
        "expected target to respond to #{@names_not_responded_to.collect {|name| name.inspect }.join(', ')}"
      end
      
      def negative_failure_message
        "expected target not to respond to #{@names.collect {|name| name.inspect }.join(', ')}"
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/lib/spec/matchers/respond_to.rb
      end
      
      def description
        "respond to ##{@names.to_s}"
      end
    end
    
    # :call-seq:
    #   should respond_to(*names)
    #   should_not respond_to(*names)
    #
    # Matches if the target object responds to all of the names
    # provided. Names can be Strings or Symbols.
    #
    # == Examples
    # 
    def respond_to(*names)
      Matchers::RespondTo.new(*names)
    end
  end
end
