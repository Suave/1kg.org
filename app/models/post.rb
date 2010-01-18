# == Schema Information
#
# Table name: posts
#
#  id                  :integer(4)      not null, primary key
#  topic_id            :integer(4)      not null
#  user_id             :integer(4)      not null
#  body_html           :text
#  created_at          :datetime
#  updated_at          :datetime
#  last_modified_at    :datetime
#  last_modified_by_id :integer(4)
#  deleted_at          :datetime
#  clean_html          :text
#

class Post < ActiveRecord::Base
  include BodyFormat
  
  belongs_to :topic, :counter_cache => 'posts_count'
  belongs_to :user
  
  acts_as_paranoid
  
  before_save :format_content
  after_create :update_last_replied
  
  named_scope :available, :conditions => {:deleted_at => nil}
  
  def editable_by(user)
    user != nil && (self.user_id == user.id || self.topic.board.has_moderator?(user) || user.admin?)
  end
  
  def html
    self.clean_html ||= sanitize(self.body_html, true)
  end
  
  private
  def format_content
    self.clean_html = sanitize(self.body_html, true)
  end
  
  def update_last_replied
    self.topic.last_replied_at = self.created_at
    self.topic.last_replied_by_id = self.user_id
    self.topic.save(false)
  end
end
