class Following < ActiveRecord::Base
  belongs_to :followable, :polymorphic => true
  belongs_to :follower, :class_name => "User"
  
  named_scope :schools, :conditions => {:followable_type => 'School'}
  named_scope :users, :conditions => {:followable_type => 'User'}
end