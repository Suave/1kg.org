class AddRbacSchema < ActiveRecord::Migration
  def self.up
    raise "Please review the AddRbacSchema migration and remove this line!"

    say "Creating table 'users' and indexes..."
    
    ActiveRecord::Base.transaction do
      say "Create table users.", true
      create_table(:users) do |t|
        t.column :created_at,         :timestamp, :null => false
        t.column :updated_at,         :timestamp, :null => false
      
        # email also is the user's login
        t.column :email,              :string,    :limit => 100, :null => false
        
        t.column :password,           :string,    :limit => 128, :null => false # sha-512 ready
        t.column :password_salt,      :string,    :limit => 100, :null => false
        t.column :password_hash_type, :string,    :limit =>  10, :null => false
      end
    
      say "Add indexes.", true
      add_index :users, :email
      
      say "Create table roles.", true
      create_table(:roles) do |t|
        t.column :created_at,         :timestamp, :null => false
        t.column :updated_at,         :timestamp, :null => false
      
        t.column :identifier,         :string,    :limit => 100, :null => false
      end
    
      say "Add indexes on table 'roles'.", true
      add_index :roles, :identifier
      
      say "Add relation table roles <---> users", true
      create_table(:roles_users, :id => false) do |t|
        t.column :role_id,            :integer, :null => false
        t.column :user_id,            :integer, :null => false
      end
      
      say "Add indexes on 'roles_users'", true
      add_index :roles_users, [ :role_id, :user_id ], :unique => true

      say "Create table 'static_permissions'.", true
      create_table(:static_permissions) do |t|
        t.column :created_at,         :timestamp, :null => false
        t.column :updated_at,         :timestamp, :null => false

        t.column :identifier,         :string,    :limit => 100, :null => false
      end

      say "Add indexes on table 'static_permissions'.", true
      add_index :static_permissions, :identifier

      say "Add relation table roles <---> static_permissions", true
      create_table(:roles_static_permissions, :id => false) do |t|
        t.column :role_id,              :integer, :null => false
        t.column :static_permission_id, :integer, :null => false
      end

      say "Add indexes on 'roles_static_permissions'", true
      add_index :roles_static_permissions, [ :role_id, :static_permission_id ], :unique => true
    end
  end

  def self.down
    ActiveRecord::Base.transaction do
      drop_table :users
      drop_table :roles_users
      drop_table :roles
      drop_table :static_permissions
      drop_table :roles_static_permissions
    end
  end
end
