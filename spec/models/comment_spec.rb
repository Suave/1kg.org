# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: comments
#
#  id               :integer(4)      not null, primary key
#  user_id          :integer(4)      not null
#  body             :text
#  body_html        :text
#  created_at       :datetime
#  updated_at       :datetime
#  type             :string(255)
#  type_id          :string(255)
#  deleted_at       :datetime
#  commentable_type :string(255)
#  commentable_id   :integer(4)
#

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
