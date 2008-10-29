class Board < ActiveRecord::Base
  belongs_to :talkable, :polymorphic => true
  has_many :topics
  
end