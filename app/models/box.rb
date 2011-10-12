class Box < ActiveRecord::Base
  belongs_to :user
  has_attached_file :image, :styles => {:box_avatar => "72x72#", :box_topic => "140x140#" }
  has_attached_file :guide
  
  named_scope :available,     :conditions => {:available => true}
  has_many :bringings, :dependent => :destroy 
  has_many :comments, :as => 'commentable', :dependent => :destroy
end
