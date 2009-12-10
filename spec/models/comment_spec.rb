require File.dirname(__FILE__) + '/../spec_helper'

describe Comment do
  fixtures :comments, :users
  
  before do
    @comment = Comment.first
    @user = User.first
  end
  
  describe 'Archives' do
    it "should only archive comments not deleted" do
      result = Comment.archives('Share')
      result.size.should == 1
      result[0][:month].should == 10
      result[0][:year].should == 2009
      result[0][:sum].should == 1
    end
  end
end