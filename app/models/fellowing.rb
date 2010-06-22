class Fellowing < ActiveRecord::Base
  belongs_to :fellowable, :polymorphic => true
  belongs_to :fellower, :class_name => "User"
  
  named_scope :schools, :conditions => {:fellowable_type => 'School'}
end