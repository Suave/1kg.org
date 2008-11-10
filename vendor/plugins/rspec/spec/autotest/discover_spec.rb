<<<<<<< HEAD:vendor/plugins/rspec/spec/autotest/discover_spec.rb
require File.dirname(__FILE__) + "/autotest_helper"
=======
require File.dirname(__FILE__) + "/../autotest_helper"
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/spec/autotest/discover_spec.rb

module DiscoveryHelper
  def load_discovery
    require File.dirname(__FILE__) + "/../../lib/autotest/discover"
  end
end


class Autotest
  describe Rspec, "discovery" do
    include DiscoveryHelper
    
    it "should add the rspec autotest plugin" do
      Autotest.should_receive(:add_discovery).and_yield
      load_discovery
    end
  end  
end
