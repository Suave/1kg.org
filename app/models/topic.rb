# == Schema Information
#
# Table name: topics
#
#  id                  :integer(4)      not null, primary key
#  board_id            :integer(4)      not null
#  user_id             :integer(4)      not null
#  title               :string(200)     not null
#  body_html           :text
#  created_at          :datetime
#  updated_at          :datetime
#  last_replied_at     :datetime
#  last_replied_by_id  :integer(4)
#  last_modified_at    :datetime
#  last_modified_by_id :integer(4)
#  deleted_at          :datetime
#  block               :boolean(1)
#  posts_count         :integer(4)      default(0)
#  sticky              :boolean(1)
#  clean_html          :text
#

class Topic < ActiveRecord::Base
  include BodyFormat
  
  acts_as_paranoid
  
  belongs_to :board, :counter_cache => 'topics_count'
  belongs_to :user
  has_many   :posts, :dependent => :destroy
  
  named_scope :unsticky,  :conditions => ["sticky=?", false]
  named_scope :in_boards_of, lambda {|board_ids| 
    { :conditions => ["topics.deleted_at is null and board_id in (?)", board_ids], 
      :order => "sticky desc, last_replied_at desc",
      :include => [:board, :user] }
  }
  named_scope :latest_updated_in, lambda{|board_class, limit|
    { :conditions => ["boards.talkable_type=?", board_class.class_name],
      :include => [:user, :board],
      :order => "last_replied_at desc",
      :limit => limit}
  }
  
  validates_presence_of :title
  
  before_save :format_content
  before_create :set_last_reply

  define_index do
    # fields
    indexes title
    indexes clean_html, :as => :content
    
    has :updated_at
    has :created_at
  end
  
  def last_replied_datetime
    (self.posts.last || self).created_at
  end
  
  def last_replied_user
    (self.posts.last || self).user
  end

  def last_modified_user
    last_modified_by_id.blank? ? nil : User.find(last_modified_by_id)
  end
  
  def last_post
    self.posts.last
  end
  
  def moderatable_by?(user)
    user.class == User && (self.board.has_moderator?(user) || user.admin?)
  end
  
  def editable_by?(user)
    (user.class == User && self.user_id == user.id) || moderatable_by?(user)
  end
  
  def deleted?
    deleted_at.nil? ? false : true
  end
  
  def self.last_10_updated_topics(board_class)
    latest_updated_in(board_class, 10)
  end
  
  def self.latest_updated_with_pagination_in(board_class, page)
    Topic.paginate( :page => page || 1, 
                              :conditions => ["boards.talkable_type=?", board_class.class_name],
                              :include => [:user, :board],
                              :joins => [:board],
                              :order => "last_replied_at desc",
                              :per_page => 20)
  end
  
  def html
    self.clean_html ||= sanitize(body_html)
  end
  
  private
  
  def set_last_reply
    self.last_replied_at = Time.now
    self.last_replied_by_id = self.user_id
  end
  
  def format_content
    self.clean_html = sanitize(body_html)
  end
  
end
