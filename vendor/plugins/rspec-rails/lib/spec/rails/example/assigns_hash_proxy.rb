module Spec
  module Rails
    module Example
      class AssignsHashProxy #:nodoc:
<<<<<<< HEAD:vendor/plugins/rspec-rails/lib/spec/rails/example/assigns_hash_proxy.rb
        def initialize(example_group, &block)
          @target = block.call
          @example_group = example_group
        end

        def [](key)
          return false if assigns[key] == false
          return false if assigns[key.to_s] == false
          assigns[key] || assigns[key.to_s] || @target.instance_variable_get("@#{key}")
        end

        def []=(key, val)
          @target.instance_variable_set("@#{key}", val)
        end

        def delete(key)
          assigns.delete(key.to_s)
          @target.instance_variable_set("@#{key}", nil)
=======
        def initialize(object)
          @object = object
        end

        def [](ivar)
          if assigns.include?(ivar.to_s)
            assigns[ivar.to_s]
          elsif assigns.include?(ivar)
            assigns[ivar]
          else
            nil
          end
        end

        def []=(ivar, val)
          @object.instance_variable_set "@#{ivar}", val
          assigns[ivar.to_s] = val
        end

        def delete(name)
          assigns.delete(name.to_s)
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec-rails/lib/spec/rails/example/assigns_hash_proxy.rb
        end

        def each(&block)
          assigns.each &block
        end

        def has_key?(key)
          assigns.key?(key.to_s)
        end

        protected
        def assigns
<<<<<<< HEAD:vendor/plugins/rspec-rails/lib/spec/rails/example/assigns_hash_proxy.rb
          @example_group.orig_assigns
=======
          @object.assigns
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec-rails/lib/spec/rails/example/assigns_hash_proxy.rb
        end
      end
    end
  end
end
