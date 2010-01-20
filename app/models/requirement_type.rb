# == Schema Information
#
# Table name: stuff_types
#
#  id               :integer(4)      not null, primary key
#  slug             :string(255)     not null
#  title            :string(255)     not null
#  description_html :text
#  created_at       :datetime
#  updated_at       :datetime
#

# StuffType定义用户可以捐赠的物资类型，如公益贺卡，公益月饼等等
class RequirementType < ActiveRecord::Base
  set_table_name "stuff_types"
  
  has_many :requirements, :foreign_key => "type_id", :dependent => :destroy
  has_many :donations, :foreign_key => "type_id", :dependent => :destroy
  
  has_attached_file :image, :styles => { :medium => "300x300>", :thumb => "150x150>" }
  
  validates_presence_of :slug, :message => "不能为空"
  validates_presence_of :title, :message => "不能为空"
  
  named_scope :exchangable, :conditions => {:exchangable => true}
  named_scope :last5, :limit => 9, :order => 'created_at DESC'
end
