# == Schema Information
#
# Table name: stuff_types
#
#  id               :integer(4)      not null, primary key
#  slug             :string(255)     not null
#  title            :string(255)     not null
#  description_html :text
#  support_html     :text
#  condition_html   :text
#  created_at       :datetime
#  updated_at       :datetime
#

# StuffType定义用户可以捐赠的物资类型，如公益贺卡，公益月饼等等
class RequirementType < ActiveRecord::Base
  set_table_name "stuff_types"
  
  attr_accessor :upload_shipping_receipt, :upload_stuff_receipt, :upload_photos, :write_process_flow
  
  has_many :requirements, :foreign_key => "type_id", :dependent => :destroy
  has_many :donations, :foreign_key => "type_id", :dependent => :destroy
  belongs_to :creator, :class_name => "User", :foreign_key => "creator_id"
  has_many :comments, :as => 'commentable', :dependent => :destroy
  
  has_attached_file :image, :styles => { :medium => "300x300>", :thumb => "150x150>" }
  
  validates_presence_of :title, :message => "不能为空"
  
  named_scope :exchangable, :conditions => {:exchangable => true}
  named_scope :non_exchangable, :conditions => {:exchangable => false}
  named_scope :validated, :conditions => "validated_at IS NOT NULL"
  named_scope :not_validated, :conditions => "validated_at IS NULL"
  named_scope :last5, :limit => 9, :order => 'created_at DESC'
  
  def before_create
    self.creator_id = User.current_user.id
  end
  
  def clean_html
    description_html
  end
  
  def validated?
    validated_at.blank? ? false : true
  end
  
  def apply_end?
    (apply_end_at < Time.now ) ? true : false
  end
  
end
