require "state_machine"

class SubDonation < ActiveRecord::Base
  belongs_to :co_donation
  belongs_to :user
  
  has_attached_file :image, :styles => {:medium => "580x580>", :thumb => "150x150>" }
  validates_presence_of :co_donation_id, :user_id, :quantity

  def validate
      if quantity.nil? || !(quantity > 0)
        errors.add(:quantity,"数量填写不正确")
      end
  end
  
  named_scope :verified, :conditions => {:verified => true}
  
  #每次修改捐赠时更新团捐数据
  def after_save
    self.co_donation.update_number!
  end
  
  #使用state_machine做捐赠的状态转换
  state_machine :state, :initial => :ordered do
    
    event :prove  do  
      transition :ordered => :proved
    end
    
    event :refuse do  
      transition [:ordered,:proved] => :refused
    end
    
    event :receive do  
      transition [:proved] => :received
    end  
    
    event :miss do  
      transition [:proved] => :missed
    end
  end    
  
end