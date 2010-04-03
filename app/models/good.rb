# == Schema Information
#
# Table name: goods
#
#  id         :integer(4)      not null, primary key
#  title      :string(255)
#  user_id    :integer(4)
#  body       :text
#  price      :string(255)
#  standard   :string(255)
#  material   :string(255)
#  color      :string(255)
#  sale_url   :text
#  serial     :string(255)
#  recommend  :boolean(1)
#  created_at :datetime
#  updated_at :datetime
#

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
