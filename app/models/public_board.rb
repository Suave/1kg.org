class PublicBoard < ActiveRecord::Base
  has_one :board, :as => :talkable
end