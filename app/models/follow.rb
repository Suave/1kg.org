class Follow < ActiveRecord::Base
  belongs_to :followable, :polymorphic => true
  belongs_to :user
  
  validates_presence_of :user_id       
  validates_uniqueness_of :user_id,   :scope => [:followable_type,:followable_id]
  validates_presence_of :followable_type
  validates_presence_of :followable_id
  
  named_scope :to_school, :conditions => {:followable_type => 'School'}
  named_scope :to_user, :conditions => {:followable_type => 'User'},:include => :followable
  named_scope :to_team, :conditions => {:followable_type => 'Team'}
end
