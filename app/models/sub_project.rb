class SubProject < ActiveRecord::Base
  attr_accessor :agree_feedback_terms
  
  belongs_to :project
  belongs_to :school
  belongs_to :user

  has_many :comments, :as => 'commentable', :dependent => :destroy
  has_many :photos, :order => "id desc", :dependent => :destroy
  has_many :shares, :order => "id desc", :dependent => :destroy
  
  validates_presence_of :school_id,:message => "必须选择一所学校"
  validates_presence_of :reason,:message => "必须填写申请理由"
  validates_presence_of :plan,:message => "必须填写实施计划"
  validates_presence_of :telephone,:message => "请留下您的电话或手机号码"
  #validates_acceptance_of :agree_feedback_terms,:message => "只有承诺反馈要求，才能申请项目"
    
  named_scope :confirmed, :conditions => ["validated = ?", true]
  named_scope :unconfirmed, :conditions => ["validated = ? or validated IS NULL", false]  
  
  def last_updated_at
    [self.created_at,self.last_modified_at,(self.shares.empty? ? nil : self.shares.last.created_at),(self.photos.empty? ? nil : self.photos.last.created_at)].compact.max
  end
  
end
