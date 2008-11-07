class School < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :geo
  belongs_to :county
  has_one    :basic, :class_name => "SchoolBasic"
  
  validates_presence_of :title
  
  
  def self.categories
    %w(小学 中学 四川灾区板房学校)
  end
  
  def school_basic=(basic_attributes)
    #logger.info("BAISC ATTRIBUTE: #{basic_attributes}")
    if basic_attributes[:id].blank?
      build_basic(basic_attributes)
    else
      basic.attributes = basic_attributes
    end
  end
end