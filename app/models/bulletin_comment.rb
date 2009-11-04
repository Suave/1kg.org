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

class BulletinComment < Comment
  belongs_to :bulletin, :foreign_key => "type_id"
  belongs_to :user
  
  after_create :update_bulletin_comments_count
  
  private
  def update_bulletin_comments_count
    self.bulletin.update_attributes!(:comments_count => BulletinComment.count(:all, :conditions => ["type_id=?", self.bulletin.id]))
  end
  
end
