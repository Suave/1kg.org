# == Schema Information
# Schema version: 20090430155946
#
# Table name: school_basics
#
#  id                  :integer         not null, primary key
#  school_id           :integer
#  address             :string(255)
#  zipcode             :integer
#  master              :string(255)
#  telephone           :string(255)
#  level_amount        :string(255)
#  teacher_amount      :string(255)
#  student_amount      :string(255)
#  class_amount        :string(255)
#  has_library         :integer(1)
#  has_pc              :integer(1)
#  has_internet        :integer(1)
#  book_amount         :integer         default(0)
#  pc_amount           :integer         default(0)
#  last_modified_at    :datetime
#  last_modified_by_id :integer
#

class SchoolBasic < ActiveRecord::Base
  belongs_to :school
    
end
