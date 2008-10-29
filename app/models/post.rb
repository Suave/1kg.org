class Post < ActiveRecord::Base
  include BodyFormat
  
  belongs_to :topic
  belongs_to :user
  
  before_save :format_content
  after_create :update_posts_count
  
  private
  def format_content
    body.strip! if body.respond_to?(:strip!)
    self.body_html = body.blank? ? '' : formatting_body_html(body)
  end
  
  def update_posts_count
    self.topic.update_attributes!(:posts_count => Post.count(:all, :conditions => {:topic_id => self.topic.id}),
                                  :last_replied_at => self.created_at,
                                  :last_replied_by_id => self.user_id)
  end
  
end