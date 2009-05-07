# == Schema Information
# Schema version: 20090430155946
#
# Table name: roles
#
#  id          :integer         not null, primary key
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#  identifier  :string(100)     default(""), not null
#  description :string(255)
#

class Role < ActiveRecord::Base
  acts_as_role
  attr_accessor :permissions
  
  def permissions_id
    static_permissions.collect{|p| p.id}
  end
  
  def permissions_identifier
    static_permissions.collect{|p| p.identifier}
  end
  
end
