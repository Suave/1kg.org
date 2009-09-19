class GuideComment < Comment
  belongs_to :user
  belongs_to :school_guide, :foreign_key => "type_id"
  
  after_create :update_guide_comments_count
  
  def self.archives
    date_func = "extract(year from created_at) as year,extract(month from created_at) as month"
    
    counts = GuideComment.find_by_sql(["select count(*) as count, #{date_func} from comments where type='GuideComment' and created_at < ? group by year,month order by year asc,month asc",Time.now])
    
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
  def update_guide_comments_count
    self.school_guide.update_attributes!(:comments_count => GuideComment.count(:all, :conditions => ["type_id=?", self.school_guide.id]),
                                         :last_replied_at => self.created_at,
                                         :last_replied_by_id => self.user_id)
  end
  
end
