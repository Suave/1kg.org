class SchoolGuide < ActiveRecord::Base
  belongs_to :school
  belongs_to :user
  
  acts_as_taggable
  
  validates_presence_of :title, :content
  
  attr_accessible :title, :content, :tag_list
end
