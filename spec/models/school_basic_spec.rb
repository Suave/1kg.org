# == Schema Information
#
# Table name: school_basics
#
#  id             :integer(4)      not null, primary key
#  school_id      :integer(4)
#  address        :string(255)
#  zipcode        :integer(4)
#  master         :string(255)
#  telephone      :string(255)
#  level_amount   :string(255)
#  teacher_amount :string(255)
#  student_amount :string(255)
#  class_amount   :string(255)
#  has_library    :integer(1)
#  has_pc         :integer(1)
#  has_internet   :integer(1)
#  book_amount    :integer(4)      default(0)
#  pc_amount      :integer(4)      default(0)
#  latitude       :string(255)
#  longitude      :string(255)
#  marked_by_id   :integer(4)
#  marked_at      :datetime
#

require File.dirname(__FILE__) + '/../spec_helper'

describe SchoolBasic do
  it "should parse address to coordinates before create a new school"
end
