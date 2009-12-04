require File.dirname(__FILE__) + '/../spec_helper'

# Be sure to include AuthenticatedTestHelper in spec/spec_helper.rb instead
# Then, you can remove it from this and the units test.
include AuthenticatedTestHelper

describe CommentsController do
  fixtures :users, :shares, :comments, :school_guides, :schools, :activities, :bulletins
  
  before do
    login_as(:quentin)
    
    @params = {:comment => {:body => 'a test comment'}}
    @commentable = {:commentable => 'Share', :share_id => 1}
    Sanitize.stub!(:clean)
  end
  
  describe 'post /comments/new' do
    describe 'with valid commentable' do
      before do
        @commentables = [{:commentable => 'SchoolGuide', :school_guide_id => 1},
                         {:commentable => 'Share', :share_id => 1},
                         {:commentable => 'Activity', :activity_id => 1},
                         {:commentable => 'Bulletin', :bulletin_id => 1}]
      end
      
      it "create a new comment with valid params" do
        @commentables.each do |commentable|
          lambda do
            post :create, commentable.merge(@params)
            response.should be_redirect
            assigns[:comment].errors.should be_empty
          end.should change(Comment, :count)
        end
      end
    end
    
    describe "with invalid commentable" do
      it "should not create new comment with invalid commentable type" do
        @commentable = {:commentable => 'invalid', :invalid_id => 1}
        lambda do
          post :create, @commentable.merge(@params) rescue
          assigns[:commentable].should be_nil
        end.should_not change(Comment, :count)
      end
      
      it "should not create new comment with invalid commentable id" do
        @commentable = {:commentable => 'Share', :share_id => 1234}
        lambda do
          post :create, @commentable.merge(@params) rescue
          assigns[:commentable].should be_nil
        end.should_not change(Comment, :count)
      end
    end
    
    describe "with invalid params" do
      it "should not create new comment with invalid comment params" do
        @params[:comment][:body] = nil
        lambda do 
          post :create, @commentable.merge(@params)
          assigns[:commentable].should_not be_nil
          assigns[:comment].errors.on(:body).should_not be_blank
        end.should_not change(Comment, :count)
      end
    end
  end

  describe "get /comments/:id/edit" do
    it "should be successful with valid comment id" do
      get :edit, @commentable.merge(:id => 1)
      response.should be_success
    end
    
    it "should raise RecordNotFound exception with invalid comment id" do
      lambda do
        get :edit, @commentable.merge(:id => 2)
      end.should raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "put /comments/:id" do
    it "should update the comment" do
      put :update, @commentable.merge(:id => 1, :comment => {:body => 'new content'})
      response.should be_redirect
      assigns[:comment].reload.body.should == 'new content'
    end
    
    it "should not update comment with invalid params" do
      put :update, @commentable.merge(:id => 1, :comment => {:body => ''})
      response.should be_redirect
      assigns[:comment].reload.body.should_not == ''
    end
  end

  describe "delete /comments/:id" do
    describe "with valid params" do
      it "should change the comment count" do
        lambda do
          delete :destroy, @commentable.merge(:id => 1)
          response.should be_redirect
        end.should change(Comment, :count)
      end
    end
    
    describe "with invalid params" do
      it "should not change the comment count" do
        lambda do
          delete(:destroy, @commentable.merge(:id => 1234))
        end.should raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end