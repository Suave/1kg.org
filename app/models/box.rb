class Box < ActiveRecord::Base
  belongs_to :user
  has_attached_file :image, :styles => {:box_topic => "300x300>", :box_avatar => "150x150>" }
  
  named_scope :published,     :conditions => {:published => true}
  named_scope :available,     :conditions => {:available => true}
  has_and_belongs_to_many :executions, :class_name =>  'Bringing'
  has_many :bringings
end
