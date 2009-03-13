require File.dirname(__FILE__) + '/../../spec_helper.rb'

module Spec
  module Mocks
    
    describe "AnyNumberOfTimes" do
      before(:each) do
        @mock = Mock.new("test mock")
      end

      it "should pass if any number of times method is called many times" do
        @mock.should_receive(:random_call).any_number_of_times
        (1..10).each do
          @mock.random_call
        end
      end

      it "should pass if any number of times method is called once" do
        @mock.should_receive(:random_call).any_number_of_times
        @mock.random_call
      end
      
      it "should pass if any number of times method is not called" do
        @mock.should_receive(:random_call).any_number_of_times
      end
<<<<<<< HEAD:vendor/plugins/rspec/spec/spec/mocks/any_number_of_times_spec.rb

      it "should return the mocked value when called after a similar stub" do
        @mock.stub!(:message).and_return :stub_value
        @mock.should_receive(:message).any_number_of_times.and_return(:mock_value)
        @mock.message.should == :mock_value
        @mock.message.should == :mock_value
      end
=======
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/spec/spec/mocks/any_number_of_times_spec.rb
    end

  end
end
