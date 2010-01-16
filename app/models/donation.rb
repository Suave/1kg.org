# == Schema Information
#
# Table name: stuffs
#
#  id             :integer(4)      not null, primary key
#  code           :string(255)     not null
#  type_id        :integer(4)      not null
#  user_id        :integer(4)
#  school_id      :integer(4)
#  matched_at     :datetime
#  created_at     :datetime
#  comment_html   :text
#  comment        :text
#  auto_fill      :boolean(1)
#  buck_id        :integer(4)
#  order_id       :string(255)
#  product_number :string(255)
#  product_serial :string(255)
#  deal_id        :string(255)
#  order_time     :string(255)
#

# 一个stuff对应用户的一次捐赠
class Donation < ActiveRecord::Base
  set_table_name 'stuffs'
  
  include BodyFormat
  
  belongs_to :type, :class_name => "StuffType", :foreign_key => :type_id
  belongs_to :buck, :class_name => "StuffBuck", :foreign_key => :buck_id
  belongs_to :user
  belongs_to :school
  
  before_save :format_content
  
  named_scope :matched, :conditions => 'matched_at is NOT NULL'
  #validates_uniqueness_of :code, :message => "密码不能重复"
  def matched?
    matched_at.blank? ? false : true
  end
  
  private
  def format_content
    self.comment_html = sanitize(comment||'')
  end
end
