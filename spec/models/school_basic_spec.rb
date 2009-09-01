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

describe SchoolBasic do
  it "should parse address to coordinates before create a new school" do
    @school_basic = SchoolBasic.new(:address => 'address')
    User.stub!(:current_user).and_return(mock(User, :id => 1))
    @school_basic.should_receive(:find_coordinates_by_address).and_return([1.1, 2.2])
    @school_basic.save
    @school_basic.latitude.should == 2.2
    @school_basic.longitude.should == 1.1
  end
end
