require "state_machine"

class SubDonation < ActiveRecord::Base
  belongs_to :co_donation
  belongs_to :user
  
  attr_accessor :action
  
  has_attached_file :image, :styles => {:prove => "580x580>" },
                            :default_style=> :prove,
                            :url=>"/system/sub_donations/:id/:style.:extension"
  validates_presence_of :co_donation_id, :user_id, :quantity
  
  scope :state_is, lambda { |state| {:conditions => {:state => state} }}
  
  scope :recent,:limit => 8,:order => "created_at desc"
  
  def description
    "认捐了#{quantity}件#{self.co_donation.goods_name}给#{self.co_donation.school.title}"
  end

  def validate
      if quantity.nil? || !(quantity > 0)
        errors.add(:quantity,"数量填写不正确")
      end
  end
  
  #每次修改捐赠时更新团捐的数据
  def after_save
    self.co_donation.update_number!
  end
  
  def after_destroy
   self.co_donation.update_number!
  end

 #使用state_machine做捐赠的状态转换,提供了一证明、拒绝、收到、丢失、等待这5个动作。
  state_machine :state, :initial => :ordered do
    
    event :prove  do  
      transition :ordered => :proved
    end
    
    event :refuse do  
      transition [:ordered,:proved,:received,:missed] => :refused
    end
    
    event :receive do  
      transition [:proved,:refused,:missed] => :received
    end  
    
    event :miss do  
      transition [:received,:proved,:refused] => :missed
    end
    
    event :wait do  
      transition [:received,:refused,:missed] => :proved
    end
  end
end
