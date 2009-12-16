require File.dirname(__FILE__) + '/../spec_helper'

describe GeosController do
  fixtures :geos
  
  describe "get /index" do
    it "should be successful" do
      get :index
      response.should be_success
    end
    
    it "should set map center to province if a province given" do
      get :index, :province => 1
      assigns[:province].should_not be_nil
      assigns[:map_center].should == [geos(:geo1).latitude, geos(:geo1).longitude, 7]
    end
  end
  
  describe "get /all" do
    it "should be redirected" do
      get :all
      response.should be_redirect
    end
  end
end