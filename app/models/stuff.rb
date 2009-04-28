class Stuff < ActiveRecord::Base
  belongs_to :type, :class_name => "StuffType", :foreign_key => :type_id
  belongs_to :buck, :class_name => "StuffBuck", :foreign_key => :buck_id
  belongs_to :user
  belongs_to :school
  
  #validates_uniqueness_of :code, :message => "密码不能重复"
  def matched?
    matched_at.blank? ? false : true
  end
  

end