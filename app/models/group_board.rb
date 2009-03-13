class GroupBoard < ActiveRecord::Base
  
  has_one :board, :as => :talkable
  belongs_to :group
    
  def board_id
    board.id
  end
  
end