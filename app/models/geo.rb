# == Schema Information
# Schema version: 20090430155946
#
# Table name: geos
#
#  id        :integer         not null, primary key
#  parent_id :integer
#  lft       :integer         not null
#  rgt       :integer         not null
#  name      :string(255)     default(""), not null
#  zipcode   :integer
#  old_id    :integer
#

class Geo < ActiveRecord::Base
  acts_as_nested_set
  
  has_many :users
  has_many :shares
  has_many :counties
  has_one  :city_board, :class_name => "CityBoard"
  
  validates_presence_of :name
  
  def self.hot_cities
    find(%w(280 273 275 304 312 356 241 322 305 239 10 299 79 1))
  end
  
end

