class Follow < ActiveRecord::Base
  belongs_to :followable, :polymorphic => true
  belongs_to :user
  
  named_scope :to_school, :conditions => {:followable_type => 'School'}
  named_scope :to_user, :conditions => {:followable_type => 'User'},:include => :followable
  named_scope :to_team, :conditions => {:followable_type => 'Team'}
end
