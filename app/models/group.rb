# == Schema Information
#
# Table name: groups
#
#  id         :integer(4)      not null, primary key
#  user_id    :integer(4)      not null
#  geo_id     :integer(4)      not null
#  title      :string(255)     not null
#  body_html  :text
#  created_at :datetime
#  updated_at :datetime
#  deleted_at :datetime
#  avatar     :string(255)
#  slug       :string(255)
#

class Group < ActiveRecord::Base
  include BodyFormat
  
  file_column :avatar, :magick => {
                              :geometry => "72x72>",
                              :versions => {"small" => "16x16", "medium" => "32x32", "large" => "48x48"}
                            }
  
  belongs_to :city,    :class_name => "Geo",  :foreign_key => "geo_id"
  belongs_to :creator, :class_name => "User", :foreign_key => "user_id"
  
  has_many :memberships, :dependent => :destroy
  has_many :members,     :through => :memberships, :source => :user
  
  has_many :topics, :as => 'boardable', :dependent => :destroy
  
  before_save  :format_content
  after_create :create_discussion
  after_create :create_feed
  
  validates_presence_of :title, :message => "请填写小组名",:within => 1..20
  validates_presence_of :geo_id, :message => "请选择小组所在城市"
  
  define_index do
    # fields
    indexes title
    indexes body_html, :as => :description
  end
  
  def joined?(user)
    user.class == User && members.include?(user)
  end

  def has_moderator?(user)
    user.has_role?("roles.group.moderator.#{self.id}")
  end
  
  def managed_by?(user)
    user.class == User &&
                  (
                    user.admin? || user.has_role?("roles.board.moderator.#{self.discussion.board.id}")
                  )
  end
  
  class << self
    def most_members
      find(:all).sort!{ |x,y| y.memberships.count <=> x.memberships.count }[0...8]
    end
  end
  
  private
  def create_discussion
    # 创建小组讨论区
    board = Board.new
    board.talkable = GroupBoard.new(:group_id => self.id)
    board.save!
    
    # 设置小组创始人为初始管理员
    role = Role.find_by_identifier("roles.board.moderator.#{board.id}")
    self.creator.roles << role
    
    # 将小组创始人设为组员
    self.members << self.creator
  end
  
  def format_content
    self.body_html = sanitize(self.body_html)
  end
  
  def create_feed
    self.creator.feed_items.create(:user_id => self.creator.id, :category => 'create_group',
                :item_id => self.id, :item_type => 'Group') if self.creator
  end
end
