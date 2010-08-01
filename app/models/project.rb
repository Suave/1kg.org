class Project < ActiveRecord::Base  
  has_attached_file :image, :styles => { :project_avatar => "60x60>", :project_logo => "200x200>" }
  named_scope :validated, :conditions => "validated_at IS NOT NULL"
  named_scope :not_validated, :conditions => "validated_at IS NULL"
  
  
  def clean_html
    description
  end
  
  def validated?
    validated_at.blank? ? false : true
  end
  
  def apply_end?
    (apply_end_at < Time.now ) ? true : false
  end
end