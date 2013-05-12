# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: school_guides
#
#  id                  :integer(4)      not null, primary key
#  title               :string(255)
#  content             :text
#  user_id             :integer(4)
#  school_id           :integer(4)
#  hits                :integer(4)      default(0)
#  created_at          :datetime
#  updated_at          :datetime
#  last_modified_by_id :integer(4)
#  last_modified_at    :datetime
#  last_replied_at     :datetime
#  comments_count      :integer(4)      default(0), not null
#  last_replied_by_id  :integer(4)
#  deleted_at          :datetime
#  clean_html          :text
#

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SchoolGuide do
  fixtures :school_guides, :users
  
  before do
    @school_guide = SchoolGuide.find(1)
    @valid_params = {:title => 'test',
                     :content => 'this is a valid content',
                     :school_id => 1, :user_id => 1}
  end

  it "should not update timestamp with increasing hit" do
    lambda do
      @school_guide.increase_hit_without_timestamping!
    end.should_not change(@school_guide, :updated_at)
  end
  
  it "should init the last repied at and last replied user id after creating a new user" do
    lambda do
      guide = SchoolGuide.create(@valid_params)
      guide.last_replied_at.should == guide.created_at
      guide.last_replied_by_id.should == guide.user_id
    end.should change(SchoolGuide, :count)
  end
end
