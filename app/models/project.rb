class Project < ActiveRecord::Base  
  belongs_to :user
  has_many:sub_projects
  has_attached_file :image, :styles => { :project_avatar => "60x60>", :project_logo => "200x200>" }
  named_scope :validated, :conditions => "validated_at IS NOT NULL"
  named_scope :not_validated, :conditions => "validated_at IS NULL"
  
  
  def clean_html
    description
  end
  
  def state_tag
    if validated
      '<span style="color:#3333cc">已验证</span>'
    elsif refused
      '<span style="color:#666666">已拒绝</span>'
    else
      '<span style="color:#999999">未验证</span>'
    end
  end
  
  def apply_end?
    (apply_end_at < Time.now ) ? true : false
  end
end