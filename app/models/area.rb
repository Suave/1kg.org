# == Schema Information
# Schema version: 20090430155946
#
# Table name: areas
#
#  id        :integer         not null, primary key
#  parent_id :integer
#  lft       :integer
#  rgt       :integer
#  title     :string(255)
#  zipcode   :integer
#

class Area < ActiveRecord::Base
 # all data is for legacy 1kg.org

end
