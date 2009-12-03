# == Schema Information
#
# Table name: visiteds
#
#  id         :integer(4)      not null, primary key
#  school_id  :integer(4)
#  user_id    :integer(4)
#  visited_at :datetime
#  status     :integer(1)
#  created_at :datetime
#  deleted_at :datetime
#  notes      :string(20)
#  wanna_at   :datetime
#

class Visited < ActiveRecord::Base
  belongs_to :school
  belongs_to :user
  
  named_scope :latest, :order => 'created_at DESC', :limit => 10,:conditions => "(status = 1)", :include => [:user, :school]
  
  acts_as_paranoid
  
  def validate
    if status == 1 && (visited_at.blank? or visited_at > Time.now.to_date)
      errors.add('日期错误')
    end
    if status == 3 && (wanna_at.blank? or wanna_at < Time.now.to_date)
      errors.add('日期错误')
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
