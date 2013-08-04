# -*- encoding : utf-8 -*-
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
  
  private
end
