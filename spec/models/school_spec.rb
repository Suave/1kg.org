# == Schema Information
#
# Table name: schools
#
#  id                       :integer(4)      not null, primary key
#  user_id                  :integer(4)
#  ref                      :string(255)
#  validated                :boolean(1)
#  meta                     :boolean(1)
#  created_at               :datetime
#  updated_at               :datetime
#  deleted_at               :datetime
#  category                 :integer(4)
#  geo_id                   :integer(4)
#  county_id                :integer(4)
#  title                    :string(255)     not null
#  last_modified_at         :datetime
#  last_modified_by_id      :integer(4)
#  validated_by_id          :integer(4)
#  validated_at             :datetime
#  hits                     :integer(4)      default(0)
#  karma                    :integer(4)      default(0)
#  last_month_average_karma :integer(4)      default(0)
#  main_photo_id            :integer(4)
#

require File.dirname(__FILE__) + '/../spec_helper'

describe School do
  fixtures :schools
  
  before do
    @school = School.find(1)
  end
  
  it "should create a new snapshot record for new school" do 
    lambda do
      @school.update_attributes(:karma => 100)
    end.should change(SchoolSnapshot, :count)
  end
  
  it "should update the existed snapshot with new karma" do
    @school.update_attributes(:karma => 100)
    SchoolSnapshot.first.karma.should == 100
    
    lambda do
      @school.update_attributes(:karma => 200)
    end.should_not change(SchoolSnapshot, :count)
    
    SchoolSnapshot.first.karma.should == 200
  end
end
