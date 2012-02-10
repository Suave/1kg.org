class Neighborhood < ActiveRecord::Base
  belongs_to :user, :class_name => "User", :foreign_key => "user_id"
  belongs_to :neighbor, :class_name => "User", :foreign_key => "neighbor_id"
  
  after_create :send_message_notification
  after_create :create_following
  before_destroy :destroy_following
  
  
  def create_following
    Following.create!(:follower_id => user.id, :followable_id => neighbor.id, :followable_type => 'User')
  end
  
  def destroy_following
    following = user.followings.find(:first, :conditions => {:followable_id => neighbor.id, :followable_type => 'User'})
    following.destroy if following
  end
end
