# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: school_snapshots
#
#  id         :integer(4)      not null, primary key
#  school_id  :integer(4)
#  karma      :integer(4)
#  created_on :date
#

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SchoolSnapshot do
  before(:each) do
    @valid_attributes = {
    }
  end

  it "should create a new instance given valid attributes" do
    SchoolSnapshot.create!(@valid_attributes)
  end
end
