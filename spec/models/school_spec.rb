# == Schema Information
# Schema version: 20090430155946
#
# Table name: users
#
#  id                        :integer(4)      not null, primary key
#  login                     :string(255)
#  email                     :string(255)
#  crypted_password          :string(40)
#  salt                      :string(40)
#  created_at                :datetime
#  updated_at                :datetime
#  remember_token            :string(255)
#  remember_token_expires_at :datetime
#  activation_code           :string(40)
#  activated_at              :datetime
#  state                     :string(255)     default("passive")
#  deleted_at                :datetime
#  avatar                    :string(255)
#  geo_id                    :integer(4)
#  old_id                    :integer(4)
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
  
  it "should not create new record if karma didn't get update" do
    lambda do
      @school.update_attributes(:title => "new title")
    end.should_not change(SchoolSnapshot, :count)
  end
end
