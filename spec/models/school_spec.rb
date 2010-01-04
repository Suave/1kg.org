# == Schema Information
#
# Table name: schools
#
#  id                  :integer(4)      not null, primary key
#  user_id             :integer(4)
#  ref                 :string(255)
#  validated           :boolean(1)
#  meta                :boolean(1)
#  created_at          :datetime
#  updated_at          :datetime
#  deleted_at          :datetime
#  category            :integer(4)
#  geo_id              :integer(4)
#  county_id           :integer(4)
#  title               :string(255)     not null
#  last_modified_at    :datetime
#  last_modified_by_id :integer(4)
#  validated_at        :datetime
#  validated_by_id     :integer(4)
#  hits                :integer(4)      default(0)
#  karma               :integer(4)      default(0)
#  main_photo_id       :integer(4)
#  last_month_karma    :integer(4)      default(0)
#

require File.dirname(__FILE__) + '/../spec_helper'

describe School do
  fixtures :schools, :geos, :users
  
  before do
    @school = School.find(1)
  end
  
  it "should create a new snapshot record for new school" do
    
    lambda do
      @school.update_attributes(:karma => 100)
    end.should change(@school.snapshots, :count)
  end
  
  it "should update the existed snapshot with new karma" do
    @school.snapshots.count.should == 0
    @school.update_attributes(:karma => 100)
    @school.snapshots.first.karma.should == 100
    @school.snapshots.count.should == 1
    
    lambda do
      @school.update_attributes(:karma => 200)
    end.should_not change(@school.snapshots, :count)
    
    @school.snapshots.count.should == 1
    @school.snapshots.first.karma.should == 200
  end
  
  it "should not create a new school if school has existed" do
    s = School.new(:title => '测试小学', :geo_id => 1)
    s.should_not be_valid
    s.errors.on(:title).should_not be_blank
  end
  
  it "should create a new school if school doesn't exist" do
    s = School.new(:title => '测试小学2', :geo_id => 1, :user_id => 1)
    s.should be_valid
  end
  
  it "should create traffic, basic, contact and finder for school automatically" do
    s = School.create(:title => '测试小学2', :geo_id => 1, :user_id => 1)
    s.should_not be_new_record
    s.traffic.should_not be_nil
    s.need.should_not be_nil
    s.contact.should_not be_nil
    s.finder.should_not be_nil
    s.local.should_not be_nil
  end
end
