# == Schema Information
# Schema version: 20090430155946
#
# Table name: visiteds
#
#  id         :integer         not null, primary key
#  school_id  :integer
#  user_id    :integer
#  visited_at :datetime
#  status     :integer(1)
#  created_at :datetime
#

class Visited < ActiveRecord::Base
  belongs_to :school
  belongs_to :user
  
  def Visited.status(status)
    case status
    when 'visited': 1
    when 'interesting': 2
    end
  end
end
