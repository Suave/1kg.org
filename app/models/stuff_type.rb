# == Schema Information
# Schema version: 20090430155946
#
# Table name: stuff_types
#
#  id               :integer         not null, primary key
#  slug             :string(255)     default(""), not null
#  title            :string(255)     default(""), not null
#  description_html :text
#  created_at       :datetime
#

class StuffType < ActiveRecord::Base
  has_many :bucks, :class_name => "StuffBuck", :foreign_key => "type_id", :dependent => :destroy
  has_many :stuffs, :class_name => "Stuff", :foreign_key => "type_id", :dependent => :destroy
  
  validates_presence_of :slug, :message => "不能为空"
  validates_presence_of :title, :message => "不能为空"
end
