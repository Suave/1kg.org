class Game < ActiveRecord::Base
  acts_as_taggable
  acts_as_versioned
  Game::Version.belongs_to :user
  
  validates_presence_of :name, :level, :length, :size, :content, :category
  
  belongs_to :user
  
  has_attached_file :photo, :styles => { :medium => "300x300>", :thumb => "150x150>" }
end