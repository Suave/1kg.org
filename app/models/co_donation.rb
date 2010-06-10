class CoDonation < ActiveRecord::Base
  belongs_to :school
  belongs_to :user
  
  attr_accessor :agree_feedback_terms
  
  has_many :sub_donations
  has_many :comments, :as => 'commentable', :dependent => :destroy
  
  has_attached_file :image, :styles => {:medium => "300x300>", :thumb => "150x150>" }
  
  validates_presence_of :school_id, :goods_name, :number, :end_at, 
      :description, :plan, :address, :receiver, :zipcode, :phone_number
    
  def still_need
    if (self.goal_number > self.number)
      self.goal_number - self.number
    else
      false
    end
  end
  
  def title
    "为#{self.school.title}捐赠#{self.goods_name}"
  end
  
  def clean_html
    self.description
  end
  
  def end?
    self.end_at < Time.now
  end
  
end