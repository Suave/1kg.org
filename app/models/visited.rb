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
  
  named_scope :latestvisit, :order => 'created_at DESC', :limit => 5,:conditions => "(status = 1)", :include => [:user, :school]
  named_scope :latestwanna, :order => 'created_at DESC', :limit => 5,:conditions => ["visited_at > ?", Time.now - 1.day], :include => [:user, :school]
  
  acts_as_paranoid
  
  def validate
    if status == 1 && (visited_at.blank? or visited_at > Time.now.to_date)
      errors.add('日期错误')
    end
    if status == 3 && (visited_at.blank? or visited_at < Time.now.to_date)
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
  
   def self.archives
    date_func = "extract(year from created_at) as year,extract(month from created_at) as month"
    
    counts = Visited.find_by_sql(["select count(*) as count, #{date_func} from visiteds where visited_at < ? and deleted_at IS NULL group by year,month order by year asc,month asc",Time.now])
    
    sum = 0
    result = counts.map do |entry|
      sum += entry.count.to_i
      {
        :name => entry.year + "年" + entry.month + "月",
        :month => entry.month.to_i,
        :year => entry.year.to_i,
        :delta => entry.count,
        :sum => sum
      }
    end
    return result.reverse
  end
  
end
