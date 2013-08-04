# -*- encoding : utf-8 -*-
class Box < ActiveRecord::Base
  belongs_to :user
  has_attached_file :guide, :url=>"/media/boxes/:id/:attachment/:style.:extension"
  has_attached_file :image, :styles => {:'280x160' => ["280x160#"],:'150x90' => ["150x90#"]},
                            :url=>"/media/boxes/:id/:attachment/:style.:extension",
                            :default_style=> :'280x160'
  
  
  scope :available,     :conditions => {:available => true}
  has_many :bringings, :dependent => :destroy 
  has_many :comments, :as => 'commentable', :dependent => :destroy
  has_many :photos, :as => 'photoable', :order => "id desc", :dependent => :destroy

end
