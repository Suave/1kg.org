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

  named_scope :recent_votes, :order => "created_at desc",
                              :limit => 8,
                              :include => [:user]
                              
  def self.find_votes_cast_by_user(user)
    find(:all,
      :conditions => ["user_id = ?", user.id],
      :order => "created_at DESC"
    )
  end
end
