# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: school_finders
#
#  id           :integer(4)      not null, primary key
#  school_id    :integer(4)
#  name         :string(255)
#  email        :string(255)
#  qq           :string(255)
#  msn          :string(255)
#  survey_at    :datetime
#  phone_number :string(255)
#  note         :text
#

class SchoolFinder < ActiveRecord::Base
  belongs_to :school
  
end
