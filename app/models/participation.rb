# == Schema Information
# Schema version: 20090430155946
#
# Table name: participations
#
#  id          :integer         not null, primary key
#  user_id     :integer
#  activity_id :integer
#  created_at  :datetime
#

class Participation < ActiveRecord::Base
  belongs_to :activity
  belongs_to :user
  
  def self.archives
    date_func = "extract(year from created_at) as year,extract(month from created_at) as month"
    
    counts = Participation.find_by_sql(["select count(*) as count, #{date_func} from participations where created_at < ? group by year,month order by year asc,month asc",Time.now])
    
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
