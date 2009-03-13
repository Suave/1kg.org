class SchoolNeed < ActiveRecord::Base
  acts_as_taggable
  
  belongs_to :school
end