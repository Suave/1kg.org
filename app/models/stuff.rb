# == Schema Information
# Schema version: 20090430155946
#
# Table name: stuffs
#
#  id           :integer(4)      not null, primary key
#  code         :string(255)     not null
#  type_id      :integer(4)      not null
#  buck_id      :integer(4)      not null
#  user_id      :integer(4)
#  school_id    :integer(4)
#  matched_at   :datetime
#  created_at   :datetime
#  comment      :text
#  comment_html :text
#

class Stuff < ActiveRecord::Base
  include BodyFormat
  
  belongs_to :type, :class_name => "StuffType", :foreign_key => :type_id
  #belongs_to :buck, :class_name => "StuffBuck", :foreign_key => :buck_id
  belongs_to :user
  belongs_to :school
  
  before_save :format_content
  
  #validates_uniqueness_of :code, :message => "密码不能重复"
  def matched?
    matched_at.blank? ? false : true
  end
  
  private
  def format_content
    comment.strip! if comment.respond_to?(:strip!)
    self.comment_html = comment.blank? ? '' : formatting_body_html(comment)
  end
end
