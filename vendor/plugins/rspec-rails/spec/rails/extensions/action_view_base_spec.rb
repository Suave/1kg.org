require File.dirname(__FILE__) + '/../../spec_helper'
require 'spec/mocks/errors'

describe ActionView::Base, "with RSpec extensions:", :type => :view do 
  
<<<<<<< HEAD:vendor/plugins/rspec-rails/spec/rails/extensions/action_view_base_spec.rb
  describe "should_receive(:render)" do
    it "should not raise when render has been received" do
      template.should_receive(:render).with(:partial => "name")
=======
  describe "expect_render" do
    it "should not raise when render has been received" do
      template.expect_render(:partial => "name")
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec-rails/spec/rails/extensions/action_view_base_spec.rb
      template.render :partial => "name"
    end
  
    it "should raise when render has NOT been received" do
<<<<<<< HEAD:vendor/plugins/rspec-rails/spec/rails/extensions/action_view_base_spec.rb
      template.should_receive(:render).with(:partial => "name")
=======
      template.expect_render(:partial => "name")
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec-rails/spec/rails/extensions/action_view_base_spec.rb
      lambda {
        template.verify_rendered
      }.should raise_error
    end
    
    it "should return something (like a normal mock)" do
<<<<<<< HEAD:vendor/plugins/rspec-rails/spec/rails/extensions/action_view_base_spec.rb
      template.should_receive(:render).with(:partial => "name").and_return("Little Johnny")
=======
      template.expect_render(:partial => "name").and_return("Little Johnny")
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec-rails/spec/rails/extensions/action_view_base_spec.rb
      result = template.render :partial => "name"
      result.should == "Little Johnny"
    end
  end
  
<<<<<<< HEAD:vendor/plugins/rspec-rails/spec/rails/extensions/action_view_base_spec.rb
  describe "stub!(:render)" do
    it "should not raise when stubbing and render has been received" do
      template.stub!(:render).with(:partial => "name")
=======
  describe "stub_render" do
    it "should not raise when stubbing and render has been received" do
      template.stub_render(:partial => "name")
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec-rails/spec/rails/extensions/action_view_base_spec.rb
      template.render :partial => "name"
    end
  
    it "should not raise when stubbing and render has NOT been received" do
<<<<<<< HEAD:vendor/plugins/rspec-rails/spec/rails/extensions/action_view_base_spec.rb
      template.stub!(:render).with(:partial => "name")
    end
  
    it "should not raise when stubbing and render has been received with different options" do
      template.stub!(:render).with(:partial => "name")
=======
      template.stub_render(:partial => "name")
    end
  
    it "should not raise when stubbing and render has been received with different options" do
      template.stub_render(:partial => "name")
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec-rails/spec/rails/extensions/action_view_base_spec.rb
      template.render :partial => "view_spec/spacer"
    end

    it "should not raise when stubbing and expecting and render has been received" do
<<<<<<< HEAD:vendor/plugins/rspec-rails/spec/rails/extensions/action_view_base_spec.rb
      template.stub!(:render).with(:partial => "name")
      template.should_receive(:render).with(:partial => "name")
=======
      template.stub_render(:partial => "name")
      template.expect_render(:partial => "name")
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec-rails/spec/rails/extensions/action_view_base_spec.rb
      template.render(:partial => "name")
    end
  end

end
