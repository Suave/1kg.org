class Good < ActiveRecord::Base
  acts_as_taggable
  
  #attr_accessor :tag_list
  attr_accessible :title, :price, :standard, :body, :user_id, :tag_list, :sale_url, :serial, :color, :material
  
  belongs_to :user
  has_many :photos, :class_name => "GoodPhoto"
  
  named_scope :recommends, :conditions => {:recommend => true}, :order => "created_at desc"
  named_scope :latest, :order => "created_at desc", :limit => 16  
  
  validates_presence_of :title, :message => "不能为空"
  validates_presence_of :serial, :message => "不能为空"
  validates_presence_of :sale_url, :message => "不能为空"
  validates_presence_of :price, :message => "不能为空"
  validates_presence_of :standard, :message => "不能为空"
  
end