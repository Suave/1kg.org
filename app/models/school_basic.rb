# -*- encoding : utf-8 -*-
# == Schema Information
#
# Table name: school_basics
#
#  id             :integer(4)      not null, primary key
#  school_id      :integer(4)
#  address        :string(255)
#  zipcode        :integer(4)
#  master         :string(255)
#  telephone      :string(255)
#  level_amount   :string(255)
#  teacher_amount :string(255)
#  student_amount :string(255)
#  class_amount   :string(255)
#  has_library    :integer(1)
#  has_pc         :integer(1)
#  has_internet   :integer(1)
#  book_amount    :integer(4)      default(0)
#  pc_amount      :integer(4)      default(0)
#  latitude       :string(255)
#  longitude      :string(255)
#  marked_by_id   :integer(4)
#  marked_at      :datetime
#


require 'gmap'
require 'open-uri'

class SchoolBasic < ActiveRecord::Base
  include GMap

  belongs_to :school
  belongs_to :village
  belongs_to :marked_by, :class_name => "User", :foreign_key => "marked_by_id"

  validates_presence_of :address, :message => "必填项"
  validates_presence_of :level_amount, :message => "必填项"
  validates_presence_of :teacher_amount, :message => "必填项"
  validates_presence_of :student_amount, :message => "必填项"
  validates_presence_of :class_amount, :message => "必填项"
  
  before_create :parse_address_to_coordinates
  
  def community
    self.school ? self.school : self.village
  end
  
  
  private
  def parse_address_to_coordinates
    #self.longitude, self.latitude = find_coordinates_by_address(self.address)
    
    #if self.longitude == DEFAULT_LONGITUDE && self.latitude == DEFAULT_LATITUDE
    self.longitude = (self.community.geo.longitude)
    self.latitude  = (self.community.geo.latitude)
    #end

    self.marked_at = Time.now
    self.marked_by_id = User.current_user.id #建议改为创建学校时直接赋值
  end
end
