# == Schema Information
# Schema version: 20090430155946
#
# Table name: counties
#
#  id      :integer(4)      not null, primary key
#  geo_id  :integer(4)
#  name    :string(255)     not null
#  zipcode :integer(4)
#  old_id  :integer(4)
#

class County < ActiveRecord::Base
  belongs_to :geo
  
  validates_presence_of :name
end
