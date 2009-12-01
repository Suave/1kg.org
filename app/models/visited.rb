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
#  wanna_at   :datetime
#  notes      :string(80)

class Visited < ActiveRecord::Base
  belongs_to :school
  belongs_to :user
  
  named_scope :latest, :order => 'created_at DESC', :limit => 10,:conditions => "(status = 1)", :include => [:user, :school]
  
  acts_as_paranoid
  
  def validate
    if status == 1 && visited_at.blank?
      errors.add('请填写日期')
    end
    if status == 3 && wanna_at.blank?
      errors.add('请填写日期')
    end
  end
  
  def Visited.status(status)
    case status
    when 'visited': 1
    when 'interesting': 2
    when 'wanna': 3
    end
  end
end
