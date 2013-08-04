# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: school_contacts
#
#  id        :integer(4)      not null, primary key
#  school_id :integer(4)
#  name      :string(255)
#  role      :string(255)
#  telephone :string(255)
#  email     :string(255)
#  qq        :string(255)
#

class SchoolContact < ActiveRecord::Base
  belongs_to :school
  
  validates_presence_of :name, :message => "必填项"
  validates_presence_of :telephone, :message => "必填项"
end
