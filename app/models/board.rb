class Board < ActiveRecord::Base
  belongs_to :talkable, :polymorphic => true
  has_many :topics
  
  after_create :create_moderator_role
  
  private
  def create_moderator_role
    Role.create!(:identifier => "roles.board.moderator.#{self.id}")
  end
  
end