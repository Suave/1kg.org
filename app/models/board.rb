# == Schema Information
# Schema version: 20090430155946
#
# Table name: boards
#
#  id                  :integer         not null, primary key
#  talkable_id         :integer         not null
#  talkable_type       :string(255)     default(""), not null
#  created_at          :datetime
#  updated_at          :datetime
#  deleted_at          :datetime
#  topics_count        :integer         default(0)
#  last_modified_at    :datetime
#  last_modified_by_id :integer
#  old_id              :integer
#

class Board < ActiveRecord::Base
  belongs_to :talkable, :polymorphic => true, :dependent => :delete
  has_many :topics, :conditions => ["deleted_at is null"], :order => "sticky desc, last_replied_at desc", :dependent => :destroy
  
  after_create :create_moderator_role
  
  def name_for_human
    if talkable.class == SchoolBoard
      "学校"
    elsif talkable.class == PublicBoard
      talkable.title
    elsif talkable.class == CityBoard
      talkable.geo.name
    end
  end
  
  def last_topic
    self.topics.find(:first, :order => "created_at desc")
  end
  
  def has_moderator?(user)
    user.has_role?("roles.board.moderator.#{self.id}")
  end
  
  def latest_topics
    topics = self.topics.find(:all, :include => [:user], 
                                    :limit => 10)
  end
  
  
  private
  def create_moderator_role
    Role.create!(:identifier => "roles.board.moderator.#{self.id}")
  end
  
end
