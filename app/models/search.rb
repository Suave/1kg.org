# == Schema Information
#
# Table name: searches
#
#  id         :integer(4)      not null, primary key
#  keywords   :string(255)
#  category   :string(255)     default("school")
#  user_id    :integer(4)
#  created_at :datetime
#  updated_at :datetime
#

class Search < ActiveRecord::Base
  attr_accessor :class_amount, :student_amount,
                :has_library, :has_pc
                
  STUDENT_RANGE = ['', '< 50', '50 - 200', '200 - 500', '500 - 1000', '> 1000']
  @@student_options = {'< 50' => 0..50,
    '50 - 200' => 50..200,
    '200 - 500' => 200..500,
    '500 - 1000' => 500..1000,
    '> 1000' => 1000..10000
  }
  
  def schools(page, per_page = 20)
    conditions = {}
    attributes = {}
    
    conditions[:title] = self.title unless self.title.blank?
    conditions[:city] = self.city unless self.city.blank?
    conditions[:need] = self.need unless self.need.blank?
    conditions[:address] = self.address unless self.address.blank?
    
    attributes[:class_amount] = self.class_amount.to_i unless self.class_amount.blank?
    attributes[:student_amount] = @@student_options[self.student_amount] unless self.student_amount.blank?
    attributes[:has_library] = true unless self.has_library.blank?
    attributes[:has_pc] = true unless self.has_pc.blank?
    
    School.search(self.q, :conditions => conditions, :with => attributes, :page => page, :per_page => per_page)
  end
  
  def advanced?
    !(self.title.blank? && self.city.blank? && self.need.blank? && 
      self.address.blank? && self.class_amount.blank? &&
      self.student_amount.blank? && self.has_library.blank? &&
      self.has_pc.blank?)
  end
end
