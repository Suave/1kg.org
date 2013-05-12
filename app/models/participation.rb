# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: participations
#
#  id          :integer(4)      not null, primary key
#  user_id     :integer(4)
#  activity_id :integer(4)
#  created_at  :datetime
#

# == Schema Information
#
# Table name: participations
#
#  id          :integer(4)      not null, primary key
#  user_id     :integer(4)
#  activity_id :integer(4)
#  created_at  :datetime
#


class Participation < ActiveRecord::Base
  belongs_to :activity, :counter_cache => true
  belongs_to :user
  
  def self.archives
    date_func = "extract(year from created_at) as year,extract(month from created_at) as month"
    
    counts = Participation.find_by_sql(["select count(*) as count, #{date_func} from participations where created_at < ? group by year,month order by year asc,month asc",Time.now])
    
    sum = 0
    result = counts.map do |entry|
      sum += entry.count.to_i
      {
        :name => "#{entry.year}年#{entry.month}月",
        :month => entry.month.to_i,
        :year => entry.year.to_i,
        :delta => entry.count,
        :sum => sum
      }
    end
    return result.reverse
  end
end
