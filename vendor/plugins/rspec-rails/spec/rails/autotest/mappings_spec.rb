require File.dirname(__FILE__) + '/../../spec_helper'
require File.join(File.dirname(__FILE__), *%w[.. .. .. lib autotest rails_rspec])
<<<<<<< HEAD:vendor/plugins/rspec-rails/spec/rails/autotest/mappings_spec.rb
require File.join(File.dirname(__FILE__), *%w[.. .. .. .. rspec spec autotest autotest_matchers])
=======
require File.join(File.dirname(__FILE__), *%w[.. .. .. .. rspec spec autotest_matchers])
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec-rails/spec/rails/autotest/mappings_spec.rb

describe Autotest::RailsRspec, "file mapping" do
  before(:each) do
    @autotest = Autotest::RailsRspec.new
    @autotest.hook :initialize
  end
  
  it "should map model example to model" do
    @autotest.should map_specs(['spec/models/thing_spec.rb']).
                            to('app/models/thing.rb')
  end
  
  it "should map controller example to controller" do
    @autotest.should map_specs(['spec/controllers/things_controller_spec.rb']).
                            to('app/controllers/things_controller.rb')
  end
  
  it "should map view.rhtml" do
    @autotest.should map_specs(['spec/views/things/index.rhtml_spec.rb']).
                            to('app/views/things/index.rhtml')
  end
  
  it "should map view.rhtml with underscores in example filename" do
    @autotest.should map_specs(['spec/views/things/index_rhtml_spec.rb']).
                            to('app/views/things/index.rhtml')
  end
  
  it "should map view.html.erb" do
    @autotest.should map_specs(['spec/views/things/index.html.erb_spec.rb']).
                            to('app/views/things/index.html.erb')
  end
  
end
