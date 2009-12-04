require File.dirname(__FILE__) + '/../spec_helper'

describe Comment do
  fixtures :comments, :users
  
  before do
    @comment = Comment.first
    @user = User.first
  end
  
  it "should not be editable if comment don't have an owner" do
    @comment.user_id = nil
    @comment.should_not be_editable_by(@user)
  end
  
  it "should not be editable without user pass" do
    @comment.should_not be_editable_by(School.first)
  end
  
  it "should be editable if user is admin" do
    @user.should_receive(:admin?).and_return(true)
    @comment.user_id = 1234
    @comment.should be_editable_by(@user)
  end
  
  it "should be editable if comment is created by user" do
    @comment.user_id = @user.id
    @comment.should be_editable_by(@user)
  end
  
  it "should not be editable if comment is not created by user and user isn't admin" do
    @user.should_receive(:admin?).and_return(false)
    @comment.user_id = 1234
    @comment.should_not be_editable_by(@user)
  end
end