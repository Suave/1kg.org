# == Schema Information
# Schema version: 20090430155946
#
# Table name: topics
#
#  id                  :integer         not null, primary key
#  board_id            :integer         not null
#  user_id             :integer         not null
#  title               :string(200)     default(""), not null
#  body                :text
#  body_html           :text
#  created_at          :datetime
#  updated_at          :datetime
#  last_replied_at     :datetime
#  last_replied_by_id  :integer
#  last_modified_at    :datetime
#  last_modified_by_id :integer
#  deleted_at          :datetime
#  block               :boolean
#  posts_count         :integer         default(0)
#  sticky              :boolean
#

class Topic < ActiveRecord::Base
  include BodyFormat
  
  belongs_to :board, :class_name => "Board", :foreign_key => "board_id"
  belongs_to :user,  :class_name => "User",  :foreign_key => "user_id"
  has_many   :posts, :dependent => :destroy
  
  named_scope :available, :conditions => "deleted_at is null"
  named_scope :unsticky,  :conditions => ["sticky=?", false]
  named_scope :in_boards_of, lambda {|board_ids| 
    { :conditions => ["deleted_at is null and board_id in (?)", board_ids], 
      :order => "sticky desc, last_replied_at desc",
      :include => [:board, :user] }
  }
  validates_presence_of :title
  
  #before_save :format_content
  after_create  :update_topics_count
  
  def last_replied_datetime
    last_replied_at.blank? ? created_at : last_replied_at
  end
  
  def last_replied_user
    last_replied_by_id.blank? ? self.user : User.find(last_replied_by_id)
  end

  def last_modified_user
    last_modified_by_id.blank? ? nil : User.find(last_modified_by_id)
  end
  
  def last_post
    self.posts.find(:first, :order => "created_at desc")
  end
  
  def moderatable_by?(user)
    user.class == User && (self.board.has_moderator?(user) || user.admin?)
  end
  
  def editable_by?(user)
    (user.class == User && self.user_id == user.id) || moderatable_by?(user)
  end
  
  
  def self.last_10_updated_topics(board_class)
    Topic.find(:all, :conditions => ["boards.talkable_type=?", board_class.class_name],
                     :include => [:user, :board],
                     :joins => [:board],
                     :order => "last_replied_at desc",
                     :limit => 10)
  end
  
  
  private
=begin
  def format_content
    body.strip! if body.respond_to?(:strip!)
    self.body_html = body.blank? ? '' : formatting_body_html(body)
  end
=end
  
  
  def update_topics_count
    self.board.update_attributes!(:topics_count => Topic.count(:all, :conditions => {:board_id => self.board.id}))
    self.update_attributes!(:last_replied_at => self.created_at, :last_replied_by_id => self.user_id)
  end
  
end
