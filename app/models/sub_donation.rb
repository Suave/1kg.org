require "state_machine"

class SubDonation < ActiveRecord::Base
  belongs_to :co_donation
  belongs_to :user
  
  attr_accessor :action
  
  has_attached_file :image, :styles => {:medium => "580x580>", :thumb => "150x150>" }
  validates_presence_of :co_donation_id, :user_id, :quantity
  
  named_scope :by_state, lambda { |state|
    {:conditions => {:state => state} }}
  
  named_scope :recent,:limit => 8,:order => "created_at desc"
  
  def description
    "认捐了#{quantity}件#{self.co_donation.goods_name}给#{self.co_donation.school.title}"
  end
  
  after_create :create_feed
  
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
  
  
  private
  def create_feed
    self.co_donation.school.feed_items.create(:user_id => self.user_id, :category => 'sub_donation',
                :item_id => self.id, :item_type => 'SubDonation') if self.co_donation && self.co_donation.school
  end
end