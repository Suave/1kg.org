require File.dirname(__FILE__) + '/../../spec_helper.rb'

describe "should respond_to(:sym)" do
  
  it "should pass if target responds to :sym" do
    Object.new.should respond_to(:methods)
  end
  
  it "should fail target does not respond to :sym" do
    lambda {
<<<<<<< HEAD:vendor/plugins/rspec/spec/spec/matchers/respond_to_spec.rb
      "this string".should respond_to(:some_method)
    }.should fail_with("expected \"this string\" to respond to :some_method")
=======
      Object.new.should respond_to(:some_method)
    }.should fail_with("expected target to respond to :some_method")
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/spec/spec/matchers/respond_to_spec.rb
  end
  
end

describe "should respond_to(message1, message2)" do
  
  it "should pass if target responds to both messages" do
    Object.new.should respond_to('methods', 'inspect')
  end
  
  it "should fail target does not respond to first message" do
    lambda {
      Object.new.should respond_to('method_one', 'inspect')
<<<<<<< HEAD:vendor/plugins/rspec/spec/spec/matchers/respond_to_spec.rb
    }.should fail_with(/expected #<Object:.*> to respond to "method_one"/)
=======
    }.should fail_with('expected target to respond to "method_one"')
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/spec/spec/matchers/respond_to_spec.rb
  end
  
  it "should fail target does not respond to second message" do
    lambda {
      Object.new.should respond_to('inspect', 'method_one')
<<<<<<< HEAD:vendor/plugins/rspec/spec/spec/matchers/respond_to_spec.rb
    }.should fail_with(/expected #<Object:.*> to respond to "method_one"/)
=======
    }.should fail_with('expected target to respond to "method_one"')
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/spec/spec/matchers/respond_to_spec.rb
  end
  
  it "should fail target does not respond to either message" do
    lambda {
      Object.new.should respond_to('method_one', 'method_two')
<<<<<<< HEAD:vendor/plugins/rspec/spec/spec/matchers/respond_to_spec.rb
    }.should fail_with(/expected #<Object:.*> to respond to "method_one", "method_two"/)
=======
    }.should fail_with('expected target to respond to "method_one", "method_two"')
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/spec/spec/matchers/respond_to_spec.rb
  end
end

describe "should_not respond_to(:sym)" do
  
  it "should pass if target does not respond to :sym" do
    Object.new.should_not respond_to(:some_method)
  end
  
  it "should fail target responds to :sym" do
    lambda {
      Object.new.should_not respond_to(:methods)
<<<<<<< HEAD:vendor/plugins/rspec/spec/spec/matchers/respond_to_spec.rb
    }.should fail_with(/expected #<Object:.*> not to respond to :methods/)
=======
    }.should fail_with("expected target not to respond to :methods")
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/spec/spec/matchers/respond_to_spec.rb
  end
  
end
