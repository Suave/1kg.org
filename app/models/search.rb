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
  OPTIONS = ['q', 'kind', 'title', 'city', 'address', 'need', 
              'category', 'on', 'include_over', 'school_title', 'content']
  
  @@student_options = {'< 50' => 0..50,
    '50 - 200' => 50..200,
    '200 - 500' => 200..500,
    '500 - 1000' => 500..1000,
    '> 1000' => 1000..10000
  }
  
  DATE_RANGE = ['最近一周', '最近一月', '今天', '周末']
  @@date_options = {
    '最近一周' => Time.now.beginning_of_day..7.day.from_now,
    '最近一月' => Time.now.beginning_of_day..30.day.from_now,
    '今天'   => Time.now.beginning_of_day..Time.now.end_of_day,
    '周末'   => (Time.now.end_of_week - 58.hour)..Time.now.end_of_week
  }
  
  def initialize(params)
    params.reject!{|k, v| !Search::OPTIONS.include?(k)}
    super(params)
  end
  
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
    
    School.search(self.q, :conditions => conditions, :with => attributes, :page => page, :per_page => per_page, :include => [:basic, :user])
  end
  
  def activities(page, per_page = 20)
    conditions = {}
    attributes = {}
    
    conditions[:title] = self.title unless self.title.blank?
    conditions[:start] = self.city unless self.city.blank?

    attributes[:category] = Activity.categories.index(self.category) unless self.category.blank?
    attributes[:end_at] = @@date_options[self.on] unless self.on.blank?
    attributes[:end_at] ||= Time.now..10.year.from_now unless self.include_over == '1'
    
    Activity.search(self.q, :conditions => conditions, 
                        :with => attributes, :page => page, 
                        :per_page => per_page,
                        :order => 'start_at DESC')
  end
  
  def shares(page, per_page = 20)
    conditions = {}
    attributes = {}
    
    conditions[:title] = self.title unless self.title.blank?
    conditions[:city] = self.city unless self.city.blank?
    conditions[:school_title] = self.school_title unless self.school_title.blank?
    conditions[:content] = self.content unless self.content.blank?
    
    Share.search(self.q, :conditions => conditions, 
                        :page => page, 
                        :per_page => per_page,
                        :order => 'updated_at DESC')
  end
  
  def groups(page, per_page = 20)
    Group.search(self.q,:page => page, 
                        :per_page => per_page)
  end
  
  def topics(page, per_page = 20)
    Topic.search(self.q,:page => page,
                        :per_page => per_page,
                        :order => 'updated_at DESC')
  end
  
  def records(page, per_page = 20)
    ThinkingSphinx.search(self.q, :page => page, :per_page => per_page)
  end
  
  def advanced?
    !(self.title.blank? && self.city.blank? && self.need.blank? && 
      self.address.blank? && self.class_amount.blank? &&
      self.student_amount.blank? && self.has_library.blank? &&
      self.has_pc.blank? && self.on.blank? &&
      self.include_over.blank? && self.school_title.blank? &&
      self.content.blank?)
  end
  
  def need_common?
    self.kind == 'school' || self.kind == 'activity' || self.kind == 'share'
  end
end
