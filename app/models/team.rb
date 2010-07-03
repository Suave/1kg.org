class Team < ActiveRecord::Base
  belongs_to :user  
  belongs_to :geo
  
  attr_accessor :agree_service_terms
  
  has_attached_file :image, :styles => { :team_icon => "32x32>",:team_logo => "160x160>"}
  
  validates_presence_of :name,:description,:user_id,:geo_id,:applicant_name,:applicant_phone,:applicant_email,:applicant_role,:category,:message=> "此项是必填项"
  validates_format_of   :applicant_email,    :with => /\A[\w\.%\+\-]+@(?:[A-Z0-9\-]+\.)+(?:[A-Z]{2}|com|org|net|edu|gov|mil|biz|info|mobi|name|aero|jobs|museum)\z/i, :message => "邮件地址格式不正确"
  validates_acceptance_of :agree_service_terms,:message => "需要同意团队要求才能申请"
  
  named_scope :validated, :conditions => {:validated => true}, :order => "created_at desc"
  named_scope :not_validated, :conditions => {:validated => false}, :order => "created_at desc"
  
  def before_create
    #为网站地址统一加上http://协议
    self.website = "http://" + self.website.gsub('http://','') unless self.website.nil?
  end
  
  
end
