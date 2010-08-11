require "state_machine"

class Project < ActiveRecord::Base  
  belongs_to :user
  has_many:sub_projects
  has_many :comments, :as => 'commentable', :dependent => :destroy
  has_attached_file :image, :styles => { :project_avatar => "60x60>", :project_logo => "200x200>" }
  named_scope :validated, :conditions => "validated_at IS NOT NULL"
  named_scope :not_validated, :conditions => "validated_at IS NULL"
  attr_accessor :action
  
  def clean_html
    description
  end
  
  def validated?
    ["validated","going","finished"].include?(status)
  end
  
  def apply_end?
    (apply_end_at < Time.now ) ? true : false
  end
  
  state_machine :status, :initial => :waiting do
  
    event :validate  do  
      transition [:refused,:waiting] => :validated
    end
    
    event :refuse do  
      transition [:waiting,:validated,:going] => :refused
    end
    
    event :start do  
      transition :validated => :going
    end  
        
    event :finish do  
      transition :going => :finished
    end
  end

end