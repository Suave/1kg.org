class RenderSpecController < ApplicationController
  set_view_path File.join(File.dirname(__FILE__), "..", "views")
  
  def some_action
    respond_to do |format|
      format.html
      format.js
    end
  end
  
  def action_which_renders_template_from_other_controller
    render :template => 'controller_spec/action_with_template'
  end
  
  def text_action
    render :text => "this is the text for this action"
  end
  
  def action_with_partial
    render :partial => "a_partial"
  end
  
  def action_that_renders_nothing
    render :nothing => true
  end
<<<<<<< HEAD:vendor/plugins/rspec-rails/spec_resources/controllers/render_spec_controller.rb
<<<<<<< HEAD:vendor/plugins/rspec-rails/spec_resources/controllers/render_spec_controller.rb
  
  def action_with_alternate_layout
    render :layout => 'simple'
  end
=======
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec-rails/spec_resources/controllers/render_spec_controller.rb
=======
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec-rails/spec_resources/controllers/render_spec_controller.rb
end
