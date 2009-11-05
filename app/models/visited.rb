# == Schema Information
# Schema version: 20090430155946
#
# Table name: visiteds
#
#  id         :integer(4)      not null, primary key
#  school_id  :integer(4)
#  user_id    :integer(4)
#  visited_at :datetime
#  status     :integer(1)
#  created_at :datetime
#

class Visited < ActiveRecord::Base
  belongs_to :school
  belongs_to :user
  
  named_scope :latest, :order => 'created_at DESC', :limit => 6
  
  def Visited.status(status)
    case status
    when 'visited': 1
    when 'interesting': 2
    end
  end
end
