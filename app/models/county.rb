# == Schema Information
#
# Table name: counties
#
#  id      :integer(4)      not null, primary key
#  geo_id  :integer(4)
#  name    :string(255)     not null
#  zipcode :integer(4)
#

class County < ActiveRecord::Base
  belongs_to :geo
  
  validates_presence_of :name
end
