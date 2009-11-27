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

class Comment < ActiveRecord::Base
  include BodyFormat
  
  before_save :format_content
  after_create :update_commentable
  belongs_to :commentable, :polymorphic => true, :counter_cache => 'comments_count'
  belongs_to :user
  
  validates_presence_of :body, :message => "留言内容不能为空"

  named_scope :available, :conditions => {:deleted_at => nil}
  
  acts_as_paranoid
  
  def editable_by?(user)
    user != nil && (self.user_id == user.id || user.admin?)
  end
  
  def self.archives(type)
    date_func = "extract(year from created_at) as year,extract(month from created_at) as month"
    
    counts = Comment.find_by_sql(["select count(*) as count, #{date_func} from comments where commentable_type = ? and created_at < ? and deleted_at is null group by year,month order by year asc,month asc", Time.now, type])
    
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
  def format_content
    body.strip! if body.respond_to?(:strip!)
    self.body_html = body.blank? ? '' : formatting_body_html(body)
  end
  
  def update_commentable
    if self.commentable.respond_to?(:last_replied_at) &&
      self.commentable.respond_to?(:last_replied_by_id)
      self.commentable.last_replied_at = self.created_at
      self.commentable.last_replied_by_id = self.user_id
      self.commentable.save(false)
    end
  end
end
