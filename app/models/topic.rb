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
  acts_as_voteable
  acts_as_taggable
  
  belongs_to :boardable, :polymorphic => true, :dependent => :delete
  belongs_to :board, :counter_cache => 'topics_count'
  belongs_to :boardable, :polymorphic => true
  belongs_to :user
  has_many   :posts, :dependent => :destroy
  
  named_scope :recent,:limit => 6,:group => :board_id,:order => "last_replied_at desc",:include => [:board]
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
  named_scope :with_activity, :order => "created_at desc, comments_count desc",
                              :conditions => {:boardable_type => 'Activity'},
                              :include => [:user]
  named_scope :with_school, :order => "created_at desc, comments_count desc",
                              :conditions => {:boardable_type => 'School'},
                              :include => [:user]
  

  validates_presence_of :title
  validates_uniqueness_of :share_id

  #before_save :format_content
  #before_create :set_last_reply
  #after_create :create_feed
  
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
    user.class == User && (self.boardable.has_moderator?(user) || user.admin?)
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
                              :per_page => 10)
  end
  
  def html
    self.clean_html
  end

  def voted_by
    self.votes[0..2].map(&:user)
  end
  
  def get_boardable
    case board.talkable.class.name
    when PublicBoard.name
      PublicBoard.find(board.talkable.id)
    when SchoolBoard.name
      School.find(board.talkable.school_id)
    when ActivityBoard.name
      Activity.find(board.talkable.activity_id)
    when GroupBoard.name
      Group.find(board.talkable.group_id)
    when Team
      Team.find(board.talkable.id)
    end
  end
 private
  
  def set_last_reply
    self.last_replied_at = Time.now
    self.last_replied_by_id = self.user_id
  end
  
  def format_content
    self.clean_html = sanitize(clean_html)
  end
  
  def create_feed
    if self.board.talkable_type == 'SchoolBoard'
      school = self.board.talkable.school
      school.feed_items.create(:content => %(#{self.user.login} 在#{self.created_at.to_date}发表了一篇关于#{school.title}新话题：#{self.title}), :user_id => self.user.id, :category => 'topic',
                :item_id => self.id, :item_type => 'Topic') if school
    end
  end
end
