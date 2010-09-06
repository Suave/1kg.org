require "state_machine"

class Project < ActiveRecord::Base  
  belongs_to :user
  has_many:executions,:include => [:school]
  has_many :comments, :as => 'commentable', :dependent => :destroy
  has_attached_file :image, :styles => { :project_avatar => "60x60>", :project_logo => "200x200>" }
  named_scope :validated, :conditions => ["state in (?)",["validated","going","finished"]]
  named_scope :not_validated, :conditions => {:state => "waiting"}
  named_scope :state_is, lambda { |state| {:conditions => {:state => state} }}
  validates_presence_of :description
  def clean_html
    description
  end
  
  def validated?
    ["validated","going","finished"].include?(state)
  end
  
  def refused?
    state == 'refused'
  end
  
  
  def apply_end?
    (apply_end_at < Time.now ) ? true : false
  end
  
  state_machine :state, :initial => :waiting do
  
    event :allow  do  
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