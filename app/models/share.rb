class Share < ActiveRecord::Base
  belongs_to :user
  belongs_to :geo
  belongs_to :activity
  belongs_to :school
  has_many :comments, :class_name => "ShareComment", :foreign_key => "type_id", :dependent => :destroy
  
  validates_presence_of :geo_id, :message => "请选择一个和你的分享有关的城市"
  validates_presence_of :title,  :message => "请起个题目"
  
  def moderated_by?(user)
    (! user.blank?) and (user_id == user.id or user.has_role?("roles.admin"))
  end
end