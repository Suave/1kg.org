require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + '/../../ruby_forker'

describe "The bin/spec script" do
  include RubyForker
  
  it "should have no warnings" do
    pending "Hangs on JRuby" if PLATFORM =~ /java/
    spec_path = "#{File.dirname(__FILE__)}/../../../bin/spec"

    output = ruby "-w #{spec_path} --help 2>&1"
    output.should_not =~ /warning/n
  end
<<<<<<< HEAD:vendor/plugins/rspec/spec/spec/package/bin_spec_spec.rb
  
  it "should show the help w/ no args" do
    pending "Hangs on JRuby" if PLATFORM =~ /java/
    spec_path = "#{File.dirname(__FILE__)}/../../../bin/spec"

    output = ruby "-w #{spec_path} 2>&1"
    output.should =~ /^Usage: spec/
  end
=======
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/spec/spec/package/bin_spec_spec.rb
end
