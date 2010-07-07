class Team < ActiveRecord::Base
  belongs_to :user  
  belongs_to :geo
  
  has_one  :board,:as => :talkable, :dependent => :destroy
  has_many :leaderships, :dependent => :destroy
  has_many :leaders,     :through => :leaderships, :source => :user
  has_many :activities
  
  has_many :fellowings, :as => "fellowable"
  has_many :fellowers, :through => :fellowings
  
  attr_accessor :agree_service_terms
  
  has_attached_file :image, :styles => { :team_icon => "64x64",:team_logo => "160x160>"}
  
  validates_presence_of :name,:description,:user_id,:geo_id,:applicant_name,:applicant_phone,:applicant_email,:applicant_role,:category,:message=> "此项是必填项"
  validates_format_of   :applicant_email,    :with => /\A[\w\.%\+\-]+@(?:[A-Z0-9\-]+\.)+(?:[A-Z]{2}|com|org|net|edu|gov|mil|biz|info|mobi|name|aero|jobs|museum)\z/i, :message => "邮件地址格式不正确"
  validates_acceptance_of :agree_service_terms,:message => "需要同意申请协议才能申请"
  validates_length_of :name, :maximum => 12
  
  named_scope :validated, :conditions => {:validated => true}, :order => "created_at desc"
  named_scope :not_validated, :conditions => {:validated => false}, :order => "created_at desc"
  
  before_create :format_website_url
  after_create :create_discussion,:set_relationship

  def appling_leaders
    self.leaderships.not_validated.map{|a| a.user}
  end
  
  def allowed_leaders
    self.leaderships.validated.map{|a| a.user}
  end
  
  #为了和User统一接口
  def login
    self.name
  end

  private
  
  def set_relationship
    #设置申请人为团队的管理员
    self.user.leaderships.build(:team_id => self.id,:validated => true,:validated_at => Time.now, :validated_by_id => 0).save
    #设置申请人为团队的关注者
    self.fellowers << self.user
  end
  
  def format_website_url
    #为网站地址统一加上http://协议
    unless (self.website.nil? || self.website.empty?)
      self.website = "http://" + self.website.gsub('http://','')
    end
  end
  
  def create_discussion
    # 创建团队讨论区
    board = Board.new
    board.talkable = self
    board.save!
    # 设置团队申请人为初始管理员
    role = Role.find_by_identifier("roles.board.moderator.#{board.id}")
    self.user.roles << role
    # 将小组创始人设为组员
  end
  
end
