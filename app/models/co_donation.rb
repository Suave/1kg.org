class CoDonation < ActiveRecord::Base
  belongs_to :school
  belongs_to :user
  
  attr_accessor :agree_feedback_terms

  has_many :sub_donations,:order => "id desc"
  has_many :comments, :as => 'commentable', :dependent => :destroy
  
  has_attached_file :image, :styles => {:medium => "300x300>", :thumb => "150x150>" }
  
  validates_presence_of :school_id, :goods_name, :number, :end_at, 
      :description, :plan, :address, :receiver, :zipcode, :phone_number,:message => "此项是必填项"
  validates_acceptance_of :agree_feedback_terms,:message => "只有承诺按要求管理和反馈，才能发起团捐"
   
  def still_need
    if (self.goal_number > self.number)
      self.goal_number - self.number
    else
      false
    end
  end
  
  def records
    self.sub_donations.by_state("received") + self.sub_donations.by_state("proved") + self.sub_donations.by_state("ordered") + self.sub_donations.by_state("missed") + self.sub_donations.by_state("refused")
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
  
  def matched_percent
    (self.number.to_f*100/self.goal_number).to_i
  end
    
  def update_number!
    self.number = (self.sub_donations.nil?? 0 : self.sub_donations.find(:all,:conditions => ["state in (?)",["ordered","received","proved"]]).map(&:quantity).sum)
    self.save
  end
  
end