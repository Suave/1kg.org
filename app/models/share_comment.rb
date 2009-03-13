class ShareComment < Comment
  belongs_to :user
  belongs_to :share, :foreign_key => "type_id"
  
  after_create :update_share_comments_count
  
  private
  def update_share_comments_count
    self.share.update_attributes!(:comments_count => ShareComment.count(:all, :conditions => ["type_id=?", self.share.id]))
  end
  
end