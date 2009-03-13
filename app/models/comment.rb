class Comment < ActiveRecord::Base
  include BodyFormat
  
  before_save :format_content
  
  validates_presence_of :body, :message => "留言内容不能为空"
  
  def editable_by?(user)
    user != nil && (self.user_id == user.id || user.admin?)
  end
  
  
  private
  def format_content
    body.strip! if body.respond_to?(:strip!)
    self.body_html = body.blank? ? '' : formatting_body_html(body)
  end
end