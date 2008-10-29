# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20081009072037) do

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "activation_code",           :limit => 40
    t.datetime "activated_at"
    t.string   "state",                                   :default => "passive"
    t.datetime "deleted_at"
    t.string   "avatar"
    t.integer  "geo_id"
  end
  add_index :users, [:email, :state]
  
  # for active-rbac (role-based authorization)
  create_table(:roles) do |t|
    t.datetime :created_at, :null => false
    t.datetime :updated_at, :null => false
  
    t.string :identifier, :limit => 100, :null => false
    t.string :description
  end
  add_index :roles, :identifier
  
  create_table(:roles_users, :id => false) do |t|
    t.integer :role_id, :null => false
    t.integer :user_id, :null => false
  end  
  add_index :roles_users, [ :role_id, :user_id ], :unique => true

  create_table(:static_permissions) do |t|
    t.datetime :created_at, :null => false
    t.datetime :updated_at, :null => false

    t.string :identifier, :limit => 100, :null => false
    t.string :description
  end
  add_index :static_permissions, :identifier

  create_table(:roles_static_permissions, :id => false) do |t|
    t.integer :role_id, :null => false
    t.integer :static_permission_id, :null => false
  end
  add_index :roles_static_permissions, [ :role_id, :static_permission_id ], :unique => true, :name => "role_id_and_static_permission_id"
  # end definition of active-rbac
  
  create_table "geos" do |t|
    t.integer :parent_id
    t.integer :lft, :null => false
    t.integer :rgt, :null => false
    t.string  :name,:null => false
    t.integer :zipcode
  end
  
  create_table "boards" do |t|
    t.integer  :talkable_id, :null => false
    t.string   :talkable_type, :null => false
    
    t.datetime :created_at
    t.datetime :updated_at
    t.datetime :deleted_at
    t.integer  :topics_count, :default => 0
    t.datetime :last_modified_at
    t.integer  :last_modified_by_id
  end
  
  create_table "public_boards" do |t|
    t.string  :title, :null => false, :limit => 100
    t.text    :description
    t.text    :description_html
    t.integer :position, :null => false, :default => 999
  end
  
  create_table "city_boards" do |t|
    t.integer :geo_id, :null => false
    t.text    :description
    t.text    :description_html
  end
  
end
