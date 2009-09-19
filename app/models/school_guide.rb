class SchoolGuide < ActiveRecord::Base
  belongs_to :school
  belongs_to :user
  has_many   :comments, :class_name => "GuideComment", :foreign_key => "type_id", :dependent => :destroy
  
  
  acts_as_taggable
  
  validates_presence_of :title, :message => "不能为空"
  validates_presence_of :content, :message => "请填写正文"
  validates_presence_of :school_id, :message => "请选择您去的学校"
  validates_presence_of :user_id
  
  attr_accessible :title, :content, :tag_list, :school_id, :user_id
end
