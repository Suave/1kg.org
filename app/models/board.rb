# == Schema Information
#
# Table name: boards
#
#  id                  :integer(4)      not null, primary key
#  talkable_id         :integer(4)      not null
#  talkable_type       :string(255)     not null
#  created_at          :datetime
#  updated_at          :datetime
#  deleted_at          :datetime
#  topics_count        :integer(4)      default(0)
#  last_modified_at    :datetime
#  last_modified_by_id :integer(4)
#

class Board < ActiveRecord::Base
  belongs_to :talkable, :polymorphic => true, :dependent => :delete
  has_many :topics, :order => "sticky desc, last_replied_at desc", :dependent => :destroy
  
  after_create :create_moderator_role
  
  acts_as_paranoid
  
  def last_topic
    self.topics.find(:first, :order => "created_at desc")
  end
  
  def has_moderator?(user)
    user.has_role?("roles.board.moderator.#{self.id}")
  end
  
  def latest_topics
    topics = self.topics.find(:all,
                              :order => "updated_at desc",
                              :include => [:user],
                              :limit => 5)
  end
  
  private
  def create_moderator_role
    Role.create!(:identifier => "roles.board.moderator.#{self.id}")
  end
  
end
