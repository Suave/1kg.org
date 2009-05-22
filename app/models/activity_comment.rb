# == Schema Information
# Schema version: 20090430155946
#
# Table name: comments
#
#  id         :integer(4)      not null, primary key
#  user_id    :integer(4)      not null
#  body       :text
#  body_html  :text
#  created_at :datetime
#  updated_at :datetime
#  type       :string(255)
#  type_id    :string(255)
#  old_id     :integer(4)
#

class ActivityComment < Comment
  belongs_to :activity, :foreign_key => "type_id"
  belongs_to :user
  
  after_create :update_activity_comments_count
  
  def self.archives
    date_func = "extract(year from created_at) as year,extract(month from created_at) as month"
    
    counts = ActivityComment.find_by_sql(["select count(*) as count, #{date_func} from comments where type='ActivityComment' and created_at < ? group by year,month order by year asc,month asc",Time.now])
    
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
  
  private
  def update_activity_comments_count
    self.activity.update_attributes!(:comments_count => ActivityComment.count(:all, :conditions => ["type_id=?", self.activity.id]))
  end
  
end
