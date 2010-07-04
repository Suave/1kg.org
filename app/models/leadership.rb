class Leadership < ActiveRecord::Base
  named_scope :validated, :conditions => {:validated => true}, :order => "created_at desc"
  named_scope :not_validated, :conditions => {:validated => false}, :order => "created_at desc"
  belongs_to :team
  belongs_to :user
end
