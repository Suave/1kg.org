class SubDonation < ActiveRecord::Base
  belongs_to :co_donation
  belongs_to :user
  
  has_attached_file :image, :styles => {:medium => "580x580>", :thumb => "150x150>" }
  
  validates_presence_of :co_donation_id, :user_id, :quantity
  
  named_scope :verified, :conditions => {:verified => true}
end