# == Schema Information
# Schema version: 20090430155946
#
# Table name: counties
#
#  id      :integer         not null, primary key
#  geo_id  :integer
#  name    :string(255)     default(""), not null
#  zipcode :integer
#  old_id  :integer
#

class County < ActiveRecord::Base
  belongs_to :geo
  
  validates_presence_of :name
end
