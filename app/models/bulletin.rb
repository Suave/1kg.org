class Bulletin < ActiveRecord::Base
  acts_as_taggable
  
  belongs_to :user
  has_many :comments, :class_name => "BulletinComment", :foreign_key => "type_id"
  
  validates_presence_of :title, :message => "不能为空"
  
  attr_accessible :title, :body, :redirect_url, :tag_list, :user_id
  
  named_scope :recent, :limit => 5, :order => 'id DESC'
end