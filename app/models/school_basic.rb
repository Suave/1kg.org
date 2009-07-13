# == Schema Information
# Schema version: 20090430155946
#
# Table name: school_basics
#
#  id                  :integer(4)      not null, primary key
#  school_id           :integer(4)
#  address             :string(255)
#  zipcode             :integer(4)
#  master              :string(255)
#  telephone           :string(255)
#  level_amount        :string(255)
#  teacher_amount      :string(255)
#  student_amount      :string(255)
#  class_amount        :string(255)
#  has_library         :integer(1)
#  has_pc              :integer(1)
#  has_internet        :integer(1)
#  book_amount         :integer(4)      default(0)
#  pc_amount           :integer(4)      default(0)
#  last_modified_at    :datetime
#  last_modified_by_id :integer(4)
#  latitude            :string(255)
#  longitude           :string(255)
#


require 'gmap'
require 'open-uri'

class SchoolBasic < ActiveRecord::Base
  include GMap

  belongs_to :school
  belongs_to :marked_by, :class_name => "User", :foreign_key => "marked_by_id"

  validates_presence_of :address, :message => "必填项"
  
  before_create :parse_address_to_coordinates
  
  private
  def parse_address_to_coordinates
    self.longitude, self.latitude = find_coordinates_by_address(self.address)
    self.marked_at = Time.now
    self.marked_by_id = User.current_user.id
  end

end
