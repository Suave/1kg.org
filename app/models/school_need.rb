# == Schema Information
# Schema version: 20090430155946
#
# Table name: school_needs
#
#  id                  :integer         not null, primary key
#  school_id           :integer
#  urgency             :string(255)
#  book                :string(255)
#  stationary          :string(255)
#  sport               :string(255)
#  cloth               :string(255)
#  accessory           :string(255)
#  course              :string(255)
#  teacher             :string(255)
#  other               :string(255)
#  last_modified_at    :datetime
#  last_modified_by_id :integer
#

class SchoolNeed < ActiveRecord::Base
  acts_as_taggable
  
  belongs_to :school
end
