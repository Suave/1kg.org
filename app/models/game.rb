class Game < ActiveRecord::Base
  acts_as_taggable
  
  validates_presence_of :name, :level, :length, :size, :content
  
  belongs_to :user
end