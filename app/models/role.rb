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