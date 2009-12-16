require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SchoolsHelper do
  include SchoolsHelper
  
  describe "radio_value" do
    it "should return 未知 if no value passed" do
      radio_value(nil).should == '未知'
      radio_value(0).should == '没有'
      radio_value(1).should == '有'
      radio_value(2).should == '未知'
    end
  end
end
