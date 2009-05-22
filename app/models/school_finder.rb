# == Schema Information
# Schema version: 20090430155946
#
# Table name: school_finders
#
#  id                  :integer(4)      not null, primary key
#  school_id           :integer(4)
#  name                :string(255)
#  email               :string(255)
#  qq                  :string(255)
#  msn                 :string(255)
#  survey_at           :datetime
#  last_modified_at    :datetime
#  last_modified_by_id :integer(4)
#

class SchoolFinder < ActiveRecord::Base
  belongs_to :school
  
end
