class Topic < ActiveRecord::Base
  include BodyFormat
  
  belongs_to :board, :class_name => "Board", :foreign_key => "board_id"
  belongs_to :user,  :class_name => "User",  :foreign_key => "user_id"
  has_many   :posts
  
  validates_presence_of :title
  
  #before_save :format_content
  after_create  :update_topics_count
  
  private
=begin
  def format_content
    body.strip! if body.respond_to?(:strip!)
    self.body_html = body.blank? ? '' : formatting_body_html(body)
  end
=end
  
  def update_topics_count
    self.board.update_attributes!(:topics_count => Topic.count(:all, :conditions => {:board_id => self.board.id}))
  end
  
end