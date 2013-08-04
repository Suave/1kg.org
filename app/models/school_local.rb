# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: school_locals
#
#  id               :integer(4)      not null, primary key
#  school_id        :integer(4)
#  incoming_from    :string(255)
#  incoming_average :string(255)
#  ngo_support      :integer(1)
#  ngo_name         :string(255)
#  ngo_start_at     :datetime
#  ngo_contact      :string(255)
#  ngo_contact_via  :string(255)
#  advice           :text
#  advice_html      :text
#  ngo_projects     :string(255)
#

class SchoolLocal < ActiveRecord::Base
  
  
  belongs_to :school
  
  before_save :format_content
  
  private
  def format_content
    self.advice_html = sanitize(advice||'', true)
  end
end
