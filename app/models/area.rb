# == Schema Information
# Schema version: 20090430155946
#
# Table name: areas
#
#  id        :integer(4)      not null, primary key
#  parent_id :integer(4)
#  lft       :integer(4)
#  rgt       :integer(4)
#  title     :string(255)
#  zipcode   :integer(4)
#

class Area < ActiveRecord::Base
 # all data is for legacy 1kg.org

end
