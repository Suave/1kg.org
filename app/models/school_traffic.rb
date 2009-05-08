# == Schema Information
# Schema version: 20090430155946
#
# Table name: school_traffics
#
#  id                  :integer         not null, primary key
#  school_id           :integer
#  sight               :string(255)
#  transport           :string(255)
#  duration            :string(255)
#  charge              :string(255)
#  description         :text
#  description_html    :text
#  last_modified_at    :datetime
#  last_modified_by_id :integer
#

class SchoolTraffic < ActiveRecord::Base
  include BodyFormat
  
  acts_as_taggable
  
  belongs_to :school
  
  before_save :format_content
  
  private
  def format_content
    description.strip! if description.respond_to?(:strip!)
    self.description_html = description.blank? ? '' : formatting_body_html(description)
  end
end
