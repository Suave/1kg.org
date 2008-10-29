class Geo < ActiveRecord::Base
  acts_as_nested_set
  
  has_many :users
  has_one  :city_board, :class_name => "CityBoard"
  
  validates_presence_of :name
end