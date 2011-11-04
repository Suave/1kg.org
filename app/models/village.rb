class Village < ActiveRecord::Base
  belongs_to :user
  belongs_to :geo
  belongs_to :main_photo, :class_name => 'Photo'
  
  has_one    :basic,   :class_name => "SchoolBasic"
  has_one    :need,    :class_name => "SchoolNeed"
  has_one    :contact,    :class_name => "SchoolContact"
  
  has_many :executions, :order => "id desc", :dependent => :destroy
  
  accepts_nested_attributes_for :basic, :need, :contact, :main_photo
  delegate :address, :zipcode, :master, :telephone, :level_amount, :teacher_amount, :student_amount, :class_amount,:intro, :to => :basic
  
  acts_as_ownable
  
  def before_create
    # 确保用户只提交了基本信息也不会出错
    self.need ||= SchoolNeed.new
    self.contact ||= SchoolContact.new
  end
  
  
end
