require File.dirname(__FILE__) + '/../spec_helper'

# Be sure to include AuthenticatedTestHelper in spec/spec_helper.rb instead
# Then, you can remove it from this and the units test.
include AuthenticatedTestHelper

describe SchoolGuidesController do
  fixtures :users, :school_guides, :schools
  
  before do
    login_as(:quentin)
    
    @school_guide = SchoolGuide.find(1)
    @params = {:school_guide => {:title => "test", :content => 'this is a valid guide'}, :school_id => 1}
  end
  
  describe "get /guides/new" do
    it "should be successful" do
      get :new, :school_id => 1
      response.should be_success
    end
  end
  
  describe 'post /guides' do
    describe 'with valid school' do
      it "create a new guide with valid params" do
        lambda do
          post :create, @params
          response.should be_redirect
          assigns[:school_guide].errors.should be_empty
        end.should change(SchoolGuide, :count)
      end
    end
    
    describe "with invalid params" do
      it "should not create new comment with invalid school" do
        @params[:school_id] = 1234
        lambda do
          post :create, @params
          assigns[:school_guide].should be_nil
        end.should raise_error(ActiveRecord::RecordNotFound)
      end
      
      it "should not create new comment with invalid params" do
        @params[:school_guide][:content] = ''
        lambda do
          post :create, @params
          assigns[:school_guide].errors[:content].should_not be_blank
        end.should_not change(SchoolGuide, :count)
      end
    end
  end

  describe "get /guides/:id/edit" do
    it "should be successful with valid guide id" do
      get :edit, {:id => 1, :school_id => 1}
      response.should be_success
    end
  end
  
  describe "put /guides/:id" do
    it "should update the guide" do
      @params[:school_guide][:content] = 'it should be updated to new content'
      put :update, @params.merge(:id => 1)
      response.should be_redirect
      assigns[:school_guide].reload.content.should == 'it should be updated to new content'
    end
    
    it "should not update comment with invalid params" do
      @params[:school_guide][:content] = 'too short'
      put :update, @params.merge(:id => 1)
      response.should render_template('school_guides/edit.html.erb')
      assigns[:school_guide].reload.content.should_not == 'too short'
    end
  end
  
  describe "get /guides/:id" do
    it "should be successful with valid id" do
      get :show, :id => 1, :school_id => 1
      response.should be_success
    end
  end
  
  describe "put /guides/1/vote" do
    it "should create a new vote if user didn't vote the guide" do
      lambda do
        put :vote, :id => 1, :school_id => 1
      end.should change(@school_guide.votes, :count)
    end
    
    it "should not create a new vote if user have voted the guide" do
      put :vote, :id => 1, :school_id => 1
      lambda do
        put :vote, :id => 1, :school_id => 1
      end.should_not change(@school_guide.votes, :count)
    end
  end

  describe "delete /guides/:id" do
    describe "with valid params" do
      it "should change the guide count" do
        lambda do
          delete :destroy, {:school_id => 1, :id => 1}
          response.should be_redirect
        end.should change(SchoolGuide, :count)
      end
    end
    
    describe "with invalid params" do
      it "should not change the guide count" do
        lambda do
          delete(:destroy, {:school_id => 1, :id => 1234})
        end.should raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end