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
  before(:each) do
    @valid_attributes = {
    }
  end

  it "should create a new instance given valid attributes" do
    SchoolGuide.create!(@valid_attributes)
  end
end
