# == Schema Information
#
# Table name: school_traffics
#
#  id               :integer(4)      not null, primary key
#  school_id        :integer(4)
#  sight            :string(255)
#  transport        :string(255)
#  duration         :string(255)
#  charge           :string(255)
#  description      :text
#  description_html :text
#

class SchoolTraffic < ActiveRecord::Base
  include 
  
  acts_as_taggable
  
  belongs_to :school
  
  before_save :format_content
  before_save :setup_tag
  validates_presence_of :description, :message => "必填项"
  
  private
  def format_content
    self.description_html = sanitize(description||'', true)
  end
  
  def setup_tag
    self.tag_list = self.sight
  end
  
end
