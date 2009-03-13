module ActionView #:nodoc:
  class Base #:nodoc:
    include Spec::Rails::Example::RenderObserver
    cattr_accessor :base_view_path
    def render_partial(partial_path, local_assigns = nil, deprecated_local_assigns = nil) #:nodoc:
      if partial_path.is_a?(String)
        unless partial_path.include?("/")
          unless self.class.base_view_path.nil?
            partial_path = "#{self.class.base_view_path}/#{partial_path}"
          end
        end
      end
<<<<<<< HEAD:vendor/plugins/rspec-rails/lib/spec/rails/extensions/action_view/base.rb
      begin
        super(partial_path, local_assigns, deprecated_local_assigns)
      rescue ArgumentError # edge rails > 2.1 changed render_partial to accept only one arg
        super(partial_path)
      end
=======
      super(partial_path, local_assigns, deprecated_local_assigns)
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec-rails/lib/spec/rails/extensions/action_view/base.rb
    end

    alias_method :orig_render, :render
    def render(options = {}, old_local_assigns = {}, &block)
<<<<<<< HEAD:vendor/plugins/rspec-rails/lib/spec/rails/extensions/action_view/base.rb
      if render_proxy.send(:__mock_proxy).send(:find_matching_expectation, :render, options)
        render_proxy.render(options)
      else
        unless render_proxy.send(:__mock_proxy).send(:find_matching_method_stub, :render, options)
=======
      if expect_render_mock_proxy.send(:__mock_proxy).send(:find_matching_expectation, :render, options)
        expect_render_mock_proxy.render(options)
      else
        unless expect_render_mock_proxy.send(:__mock_proxy).send(:find_matching_method_stub, :render, options)
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec-rails/lib/spec/rails/extensions/action_view/base.rb
          orig_render(options, old_local_assigns, &block)
        end
      end
    end
  end
end
