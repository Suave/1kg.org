# == Schema Information
#
# Table name: votes
#
#  id            :integer(4)      not null, primary key
#  vote          :boolean(1)
#  created_at    :datetime        not null
#  voteable_type :string(15)      default(""), not null
#  voteable_id   :integer(4)      default(0), not null
#  user_id       :integer(4)      default(0), not null
#

class Vote < ActiveRecord::Base
  # NOTE: Votes belong to a user
  belongs_to :user
  belongs_to :voteable, :polymorphic => true
  validates_uniqueness_of :user_id, :scope => [:voteable_id,:voteable_type]

  default_scope :order => "created_at desc"
  named_scope :recent_votes, :order => "created_at desc",
                              :limit => 8,
                              :group => [:voteable_id], #严格讲，这里可能会出现分享和话题是同一个id而被忽视的情况，但是概率较底
                              :include => [:user]
                              
  def self.find_votes_cast_by_user(user)
    find(:all,
      :conditions => ["user_id = ?", user.id],
      :order => "created_at DESC"
    )
  end
end
