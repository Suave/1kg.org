class Topic < ActiveRecord::Base
  include BodyFormat
  
  belongs_to :board
  belongs_to :user
  
  before_save :format_content
  
  private
  def format_content
    body.strip! if body.respond_to?(:strip!)
    self.body_html = body.blank? ? '' : formatting_body_html(body)
  end
end