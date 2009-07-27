# == Schema Information
# Schema version: 20090430155946
#
# Table name: comments
#
#  id         :integer(4)      not null, primary key
#  user_id    :integer(4)      not null
#  body       :text
#  body_html  :text
#  created_at :datetime
#  updated_at :datetime
#  type       :string(255)
#  type_id    :string(255)
#  old_id     :integer(4)
#

class Comment < ActiveRecord::Base
  include BodyFormat
  
  before_save :format_content
  
  validates_presence_of :body, :message => "留言内容不能为空"
  
  named_scope :available, :conditions => "deleted_at is null"
  
  def editable_by?(user)
    user != nil && (self.user_id == user.id || user.admin?)
  end
  
  
  private
  def format_content
    body.strip! if body.respond_to?(:strip!)
    self.body_html = body.blank? ? '' : formatting_body_html(body)
  end
end
