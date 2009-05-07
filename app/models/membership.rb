# == Schema Information
# Schema version: 20090430155946
#
# Table name: memberships
#
#  id         :integer         not null, primary key
#  user_id    :integer         not null
#  group_id   :integer         not null
#  created_at :datetime
#

class Membership < ActiveRecord::Base
  belongs_to :group
  belongs_to :user
end
