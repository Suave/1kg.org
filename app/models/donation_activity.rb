class DonationActivity < ActiveRecord::Base
  belongs_to :school
  belongs_to :user
  
  has_attached_file :image, :styles => {:medium => "300x300>", :thumb => "150x150>" }
  
  validates_presence_of :title, :school_id, :goods_name, :number, :end_at, 
      :description, :plan, :address, :receiver, :zipcode, :phone_number
      
  def clean_html
    self.description
  end
end