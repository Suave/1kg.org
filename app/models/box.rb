class Box < ActiveRecord::Base
  belongs_to :user
  has_attached_file :image, :styles => {:box_topic => "300x300>", :box_avatar => "150x150>" }
  
  named_scope :published,     :conditions => {:published => true}
  named_scope :available,     :conditions => {:available => true}
end
