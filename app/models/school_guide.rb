class SchoolGuide < ActiveRecord::Base
  belongs_to :school
  belongs_to :user
  has_many   :comments, :class_name => "GuideComment", :foreign_key => "type_id", :dependent => :destroy
  
  acts_as_voteable
  acts_as_taggable
  
  validates_presence_of :title, :message => "不能为空"
  validates_presence_of :content, :message => "请填写正文"
  validates_presence_of :school_id, :message => "请选择您去的学校"
  validates_presence_of :user_id
  
  attr_accessible :title, :content, :tag_list, :school_id, :user_id, :last_replied_at, :last_replied_by_id, :comments_count
  
  after_create :initial_last_replied
  
  named_scope :recent, :limit => 5, :order => 'created_at DESC'
  
  def increase_hit_without_timestamping!
    self.hits += 1
    self.save_without_timestamping
  end
  
  private
  def initial_last_replied
    self.update_attributes!(:last_replied_at => self.created_at, :last_replied_by_id => self.user_id)
  end
end
