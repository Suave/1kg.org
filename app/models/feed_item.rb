class FeedItem < ActiveRecord::Base
  belongs_to :owner, :polymorphic => true
  belongs_to :item, :polymorphic => true
  belongs_to :user
end