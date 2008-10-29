class Board < ActiveRecord::Base
  belongs_to :talkable, :polymorphic => true
  
end