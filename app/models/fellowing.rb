class Fellowing < ActiveRecord::Base
  belongs_to :fellowable, :polymorphic => true
  belongs_to :fellower, :class_name => "User"
  
  named_scope :schools, :conditions => {:fellowable_type => 'School'}
  named_scope :users, :conditions => {:fellowable_type => 'User'}
end