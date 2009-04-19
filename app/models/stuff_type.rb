class StuffType < ActiveRecord::Base
  has_many :bucks, :class_name => "StuffBuck", :foreign_key => "type_id", :dependent => :destroy
  has_many :stuffs, :class_name => "Stuff", :foreign_key => "type_id", :dependent => :destroy
  
  validates_presence_of :slug, :message => "不能为空"
  validates_presence_of :title, :message => "不能为空"
end