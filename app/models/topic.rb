
class Topic < ActiveRecord::Base
  include BodyFormat
  
  acts_as_paranoid
  acts_as_voteable
  acts_as_taggable
  acts_as_ownable
  
  belongs_to :boardable, :polymorphic => true, :dependent => :delete
  belongs_to :user
  has_many   :posts, :dependent => :destroy
  has_many   :comments, :as => 'commentable', :dependent => :destroy
  
  named_scope :recent,:limit => 6,:order => "last_replied_at desc"
  named_scope :unsticky,  :conditions => ["sticky=?", false]

  named_scope :latest_updated_in, lambda{|board_class, limit|
    { :conditions => {:boardable_type => board_class.class_name},
      :include => [:user],
      :order => "last_replied_at desc",
      :limit => limit}
  }
  named_scope :with_activity, :order => "created_at desc, comments_count desc",
                              :conditions => {:boardable_type => 'Activity'},
                              :include => [:user]
  named_scope :with_school, :order => "created_at desc, comments_count desc",
                              :conditions => {:boardable_type => 'School'},
                              :include => [:user]
  

  before_save :format_content
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
    (self.comments.last || self).created_at
  end
  
  def last_replied_user
    (self.comments.last || self).user
  end

  def last_modified_user
    last_modified_by_id.blank? ? nil : User.find(last_modified_by_id)
  end
    
  def deleted?
    deleted_at.nil? ? false : true
  end
  
  def self.last_10_updated_topics(boadable)
    latest_updated_in(boardable, 10)
  end
  
  def self.latest_updated_with_pagination_in(board_class, page)
    Topic.paginate( :page => page || 1, 
                              :conditions => ["boards.talkable_type=?", board_class.class_name],
                              :include => [:user],
                              :order => "last_replied_at desc",
                              :per_page => 10)
  end
  
  def html
    self.clean_html
  end

  def voted_by
    self.votes[0..2].map(&:user)
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
  
  end
end
