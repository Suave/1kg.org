class Good < ActiveRecord::Base
  acts_as_taggable
  
  #attr_accessor :tag_list
  attr_accessible :title, :price, :standard, :body, :user_id, :tag_list
  
  belongs_to :user
  
  validates_presence_of :title, :message => "不能为空"
  validates_presence_of :serial, :message => "不能为空"
  validates_presence_of :sale_url, :message => "不能为空"
  validates_presence_of :price, :message => "不能为空"
  validates_presence_of :standard, :message => "不能为空"
  
end