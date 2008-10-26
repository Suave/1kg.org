class InsertRbacRecords < ActiveRecord::Migration
  def self.up
    raise "Please review the InsertRbacRecords migration and remove this line!"
    
    say_with_time 'Adding initial roles and permissions...' do
      ActiveRecord::Base.transaction do
        # -----------------------------------------------------------------------------
        # Add roles.
        
        Role.new(:identifier => 'roles.admin').save!
        Role.new(:identifier => 'roles.user').save!
        
        # -----------------------------------------------------------------------------
        # Add permissions.

        # permissions.admin.all allows permissions to all parts of the administration.
        StaticPermission.new(:identifier => 'permissions.admin.all').save!

        # -----------------------------------------------------------------------------
        # Grant permissions to roles.
        
        admin_role = Role.find_by_identifier('roles.admin')
        admin_role.static_permissions << StaticPermission.find_by_identifier('permissions.admin.all')
        admin_role.save!

        # user_role = Role.find_by_identifier('roles.user')
        # user_role.save!
      end
    end
  end

  def self.down
    say_with_time 'Deleting initial roles and permissions...' do
      ActiveRecord::Base.transaction do
        [ 'permissions.admin.all' ].each do |identifier|
          StaticPermission.find_by_identifier(identifier).destroy rescue puts "StaticPermission #{identifier} has already been removed."
        end

        [ 'roles.admin', 'roles.user' ].each do |identifier|
          Role.find_by_identifier(identifier).destroy rescue puts "Role #{identifier} has already been removed."
        end
      end
    end
  end
end
