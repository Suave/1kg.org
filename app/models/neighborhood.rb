# == Schema Information
# Schema version: 20090430155946
#
# Table name: neighborhoods
#
#  id          :integer         not null, primary key
#  user_id     :integer         not null
#  neighbor_id :integer         not null
#  created_at  :datetime
#  old_id      :integer
#

class Neighborhood < ActiveRecord::Base
  belongs_to :user, :class_name => "User", :foreign_key => "user_id"
  belongs_to :neighbor, :class_name => "User", :foreign_key => "neighbor_id"
  
  after_create :send_message_notification
  
  private
  def send_message_notification
    title = "#{self.user.login}刚刚加你为好友了"
    content = "#{self.neighbor.login}，\r\n\r\n" + 
              "#{self.user.login}刚刚加你为好友，去他/她的主页( http://www.1kg.org/users/#{self.user.id} )看看吧\r\n\r\n\r\n\r\n\r\n\r\n" +
              "多背一公斤客服"
    #Message.create_system_notification([self.neighbor_id], title, content)    
    msg = Message.new
    msg.author_id = 0
    msg.to = [self.neighbor_id]
    msg.subject = title
    msg.content = content
    msg.save!
  end
  
end
