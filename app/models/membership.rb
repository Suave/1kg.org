# == Schema Information
# Schema version: 20090430155946
#
# Table name: memberships
#
#  id         :integer(4)      not null, primary key
#  user_id    :integer(4)      not null
#  group_id   :integer(4)      not null
#  created_at :datetime
#

class Membership < ActiveRecord::Base
  belongs_to :group
  belongs_to :user
  
  #after_create :create_feed
  
  private
  def create_feed
    self.user.feed_items.create(:user_id => self.user.id, :category => 'join_group',
    :item_id => self.group_id, :item_type => 'Group') if self.user
  end
end
