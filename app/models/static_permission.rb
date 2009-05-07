# == Schema Information
# Schema version: 20090430155946
#
# Table name: static_permissions
#
#  id          :integer         not null, primary key
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#  identifier  :string(100)     default(""), not null
#  description :string(255)
#

class StaticPermission < ActiveRecord::Base
  acts_as_static_permission
end
