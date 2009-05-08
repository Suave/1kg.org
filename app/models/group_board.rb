class GroupBoard < ActiveRecord::Base
  
  has_one :board, :as => :talkable, :dependent => :destroy
  belongs_to :group
    
  def board_id
    board.id
  end
  
end