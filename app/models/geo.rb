# == Schema Information
#
# Table name: geos
#
#  id        :integer(4)      not null, primary key
#  parent_id :integer(4)
#  lft       :integer(4)      not null
#  rgt       :integer(4)      not null
#  name      :string(255)     not null
#  zipcode   :integer(4)
#  slug      :string(255)
#  latitude  :string(255)
#  longitude :string(255)
#

class Geo < ActiveRecord::Base
  acts_as_nested_set
  
  has_many :users, :order => "id desc"
  has_many :shares, :order => "last_replied_at desc"
  has_many :groups, :order => "id desc"
  has_many :counties
  has_one  :city_board, :class_name => "CityBoard" # deprecated, but use in city board convert rake task
  
  validates_presence_of :name
  
  DEFAULT_CENTER = [36.960223,106.445313,4]
  
  def self.hot_cities
    find(%w(280 273 275 304 312 356 241 322 305 239 10 299 79 1))
  end
  
  def full_name
    self.parent ? self.parent.full_name + self.name : self.name
  end
end

