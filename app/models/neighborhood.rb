# == Schema Information
#
# Table name: neighborhoods
#
#  id          :integer(4)      not null, primary key
#  user_id     :integer(4)      not null
#  neighbor_id :integer(4)      not null
#  created_at  :datetime
#

class Neighborhood < ActiveRecord::Base
  belongs_to :user, :class_name => "User", :foreign_key => "user_id"
  belongs_to :neighbor, :class_name => "User", :foreign_key => "neighbor_id"
  
  after_create :send_message_notification
  after_create :create_following
  before_destroy :destroy_following
  
  private
  def send_message_notification
    title = "#{self.user.login}刚刚加你为好友了"
    content = "<p>你好，#{self.neighbor.login}：</p><br/>" + 
              "<p>#{self.user.login}刚刚加你为好友，去他/她的主页( http://www.1kg.org/users/#{self.user.id} )看看吧。</p>" +
              "<br/><p>-多背一公斤团队</p>"
    #Message.create_system_notification([self.neighbor_id], title, content)    
    msg = Message.new
    msg.author_id = 0
    msg.to = [self.neighbor_id]
    msg.subject = title
    msg.content = content
    msg.save!
  end
  
  def create_following
    Following.create!(:follower_id => user.id, :followable_id => neighbor.id, :followable_type => 'User')
    self.user.feed_items.create(:content => %(#{self.user.login} 关注了#{self.neighbor.login}), :user_id => self.user.id, :category => 'neighborhood',
                :item_id => self.id, :item_type => 'Neighborhood') if self.neighbor
  end
  
  def destroy_following
    following = user.followings.find(:first, :conditions => {:followable_id => neighbor.id, :followable_type => 'User'})
    following.destroy if following
  end
end
