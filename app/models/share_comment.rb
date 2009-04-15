class ShareComment < Comment
  belongs_to :user
  belongs_to :share, :foreign_key => "type_id"
  
  after_create :update_share_comments_count
  
  def self.archives
    date_func = "extract(year from created_at) as year,extract(month from created_at) as month"
    
    counts = ShareComment.find_by_sql(["select count(*) as count, #{date_func} from comments where type='ShareComment' and created_at < ? group by year,month order by year asc,month asc",Time.now])
    
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
  def update_share_comments_count
    self.share.update_attributes!(:comments_count => ShareComment.count(:all, :conditions => ["type_id=?", self.share.id]),
                                  :last_replied_at => self.created_at,
                                  :last_replied_by_id => self.user_id)
  end
  
end