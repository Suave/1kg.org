require File.dirname(__FILE__) + '/../../spec_helper.rb'

module Spec
  module Mocks
    describe "calling :should_receive with an options hash" do
<<<<<<< HEAD:vendor/plugins/rspec/spec/spec/mocks/options_hash_spec.rb
<<<<<<< HEAD:vendor/plugins/rspec/spec/spec/mocks/options_hash_spec.rb
      it "should report the file and line submitted with :expected_from" do
        begin
          mock = Spec::Mocks::Mock.new("a mock")
          mock.should_receive(:message, :expected_from => "/path/to/blah.ext:37")
          mock.rspec_verify
        rescue => e
        ensure
          e.backtrace.to_s.should =~ /\/path\/to\/blah.ext:37/m
        end
      end

      it "should use the message supplied with :message" do
        lambda {
          m = Spec::Mocks::Mock.new("a mock")
          m.should_receive(:message, :message => "recebi nada")
          m.rspec_verify
        }.should raise_error("recebi nada")
      end
      
      it "should use the message supplied with :message after a similar stub" do
        lambda {
          m = Spec::Mocks::Mock.new("a mock")
          m.stub!(:message)
          m.should_receive(:message, :message => "from mock")
          m.rspec_verify
        }.should raise_error("from mock")
=======
=======
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/spec/spec/mocks/options_hash_spec.rb
      include SandboxedOptions
      attr_reader :reporter, :example_group
      before do
        @reporter = ::Spec::Runner::Reporter.new(options)
        @example_group = Class.new(::Spec::Example::ExampleGroup) do
          plugin_mock_framework
          describe("Some Examples")
        end
        reporter.add_example_group example_group
      end

      it "should report the file and line submitted with :expected_from" do
        example_definition = example_group.it "spec" do
          mock = Spec::Mocks::Mock.new("a mock")
          mock.should_receive(:message, :expected_from => "/path/to/blah.ext:37")
          mock.rspec_verify
        end
        example = example_group.new(example_definition)
        
        reporter.should_receive(:example_finished) do |spec, error|
          error.backtrace.detect {|line| line =~ /\/path\/to\/blah.ext:37/}.should_not be_nil
        end
        example.execute(options, {})
      end

      it "should use the message supplied with :message" do
        example_definition = @example_group.it "spec" do
          mock = Spec::Mocks::Mock.new("a mock")
          mock.should_receive(:message, :message => "recebi nada")
          mock.rspec_verify
        end
        example = @example_group.new(example_definition)
        @reporter.should_receive(:example_finished) do |spec, error|
          error.message.should == "recebi nada"
        end
        example.execute(@options, {})
<<<<<<< HEAD:vendor/plugins/rspec/spec/spec/mocks/options_hash_spec.rb
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/spec/spec/mocks/options_hash_spec.rb
=======
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/spec/spec/mocks/options_hash_spec.rb
      end
    end
  end
end
