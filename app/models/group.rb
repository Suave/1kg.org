# == Schema Information
# Schema version: 20090430155946
#
# Table name: groups
#
#  id         :integer         not null, primary key
#  user_id    :integer         not null
#  geo_id     :integer         not null
#  title      :string(255)     default(""), not null
#  body_html  :text
#  created_at :datetime
#  updated_at :datetime
#  deleted_at :datetime
#  avatar     :string(255)
#

class Group < ActiveRecord::Base
  file_column :avatar, :magick => {
                              :geometry => "72x72>",
                              :versions => {"small" => "16x16", "medium" => "32x32", "large" => "48x48"}
                            }
  
  belongs_to :city,    :class_name => "Geo",  :foreign_key => "geo_id"
  belongs_to :creator, :class_name => "User", :foreign_key => "user_id"
  
  has_many :memberships, :dependent => :destroy
  has_many :members,     :through => :memberships, :source => :user
  
  has_one  :discussion,  :class_name => "GroupBoard"
  
  after_create :create_discussion
  
  validates_presence_of :title, :message => "请填写小组名"
  validates_presence_of :geo_id, :message => "请选择小组所在城市"
  
  def joined?(user)
    user.class == User && members.include?(user)
  end
  
  def managed_by?(user)
    user.class == User &&
                  (
                    user.admin? || user.has_role?("roles.board.moderator.#{self.discussion.board.id}")
                  )
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
  
end
