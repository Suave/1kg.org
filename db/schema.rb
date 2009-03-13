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
    t.integer  "old_id"
  end
  add_index :users, [:email, :state]
  
  create_table "profiles", :force => true do |t|
    t.integer   :user_id
    t.string    :blog_url
    t.text      :bio
    t.text      :bio_html
    t.string    :last_name
    t.string    :first_name
    t.integer   :gender,      :limit => 1
    t.date      :birth
    t.string    :phone
    t.integer   :privacy,     :limit => 1
  end
  
  create_table :neighborhoods do |t|
    t.integer   :user_id,   :null => false
    t.integer   :neighbor_id, :null => false
    t.datetime  :created_at
    t.integer   :old_id
  end
  
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
  
  #temp setup areas table for data migration
  create_table "areas" do |t|
    t.integer :parent_id
    t.integer :lft, :null => false
    t.integer :rgt, :null => false
    t.string  :title,:null => false
    t.integer :zipcode
  end
  
  create_table "geos" do |t|
    t.integer :parent_id
    t.integer :lft, :null => false
    t.integer :rgt, :null => false
    t.string  :name,:null => false
    t.integer :zipcode
    t.integer :old_id # save original id in the old database
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
    t.integer  :old_id
  end
  
  create_table "public_boards" do |t|
    t.string   :title, :null => false, :limit => 100
    t.text     :description
    t.text     :description_html
    t.integer  :position, :null => false, :default => 999
  end
  
  create_table "city_boards" do |t|
    t.integer :geo_id, :null => false
    t.text    :description
    t.text    :description_html
  end
  
  create_table "activity_boards" do |t|
    t.integer :activity_id, :null => false
    t.text    :description
    t.text    :description_html
  end
  
  create_table "school_boards" do |t|
    t.integer :school_id, :null => false
    t.text    :description
    t.text    :description_html
  end
  
  create_table  "group_boards" do |t|
    t.integer :group_id, :null => false
  end
  
  create_table "topics" do |t|
    t.integer   :board_id, :null => false
    t.integer   :user_id,  :null => false
    t.string    :title,    :null => false, :limit => 200
    t.text      :body
    t.text      :body_html
    t.datetime  :created_at
    t.datetime  :updated_at
    t.datetime  :last_replied_at
    t.integer   :last_replied_by_id
    t.datetime  :last_modified_at
    t.integer   :last_modified_by_id
    t.datetime  :deleted_at
    t.boolean   :stiky, :default => false
    t.boolean   :block, :default => false
    t.integer   :posts_count, :default => 0
  end
  
  create_table "posts" do |t|
    t.integer   :topic_id, :null => false
    t.integer   :user_id,  :null => false
    t.text      :body
    t.text      :body_html
    t.datetime  :created_at
    t.datetime  :updated_at
    t.datetime  :last_modified_at
    t.integer   :last_modified_by_id
    t.datetime  :deleted_at
  end
  
  create_table "activities" do |t|
    t.integer   :user_id,     :null => false
    t.integer   :school_id
    t.boolean   :done,        :default => false # 活动是否结束
    t.datetime  :created_at
    t.datetime  :updated_at
    t.datetime  :deleted_at
    t.string    :ref
    t.integer   :category,    :null => false
    t.string    :title,       :null => false
    t.string    :location,    :null => false
    t.integer   :departure_id,   :null => false
    t.integer   :arrival_id,     :null => false
    t.datetime  :start_at
    t.datetime  :end_at
    t.datetime  :register_over_at
    t.string    :expense_per_head
    t.string    :expect_strength
    t.text      :description
    t.text      :description_html
    t.integer   :comments_count,  :default => 0
    t.integer   :old_id
  end
  
  create_table "participations" do |t|
    t.integer   :user_id
    t.integer   :activity_id
    #t.integer   :status,        :limit => 1 # 1 => participation, 2 => interesting
    t.datetime  :created_at
  end
  
  create_table "photos" do |t|
    t.integer   :parent_id
    t.string    :content_type
    t.string    :filename
    t.string    :thumbnail
    t.integer   :size
    t.integer   :width
    t.integer   :height
    t.integer   :user_id
    t.string    :title,             :null => false
    t.text      :description
    t.text      :description_html
    t.datetime  :created_at
    t.datetime  :updated_at
    t.datetime  :deleted_at
  end
  
  create_table "counties" do |t|
    t.integer   :geo_id
    t.string    :name,      :null => false
    t.integer   :zipcode
    t.integer   :old_id
  end
  
  create_table "schools" do |t|
    t.integer   :user_id
    t.string    :ref
    t.boolean   :validated,     :default => false
    t.boolean   :meta,          :default => false
    t.datetime  :created_at
    t.datetime  :updated_at
    t.datetime  :deleted_at
    t.integer   :category
    t.integer   :geo_id
    t.integer   :county_id
    t.string    :title,         :null => false
    t.datetime  :last_modified_at
    t.integer   :last_modified_by_id
    t.integer   :old_id
  end
  
  create_table "school_basics" do |t|
    t.integer   :school_id
    t.string    :address
    t.integer   :zipcode
    t.string    :master
    t.string    :telephone
    t.string    :level_amount
    t.string    :teacher_amount
    t.string    :student_amount
    t.string    :class_amount
    t.integer   :has_library,         :limit => 1
    t.integer   :has_pc,              :limit => 1
    t.integer   :has_internet,        :limit => 1
    t.integer   :book_amount,         :default => 0
    t.integer   :pc_amount,           :default => 0
    t.datetime  :last_modified_at
    t.integer   :last_modified_by_id
  end
  
  create_table "school_traffics" do |t|
    t.integer   :school_id
    t.string    :sight
    t.string    :transport
    t.string    :duration
    t.string    :charge
    t.text      :description
    t.text      :description_html
    t.datetime  :last_modified_at
    t.integer   :last_modified_by_id
  end
  
  create_table "school_needs" do |t|
    t.integer   :school_id
    t.string    :urgency
    t.string    :book
    t.string    :stationary
    t.string    :sport
    t.string    :cloth
    t.string    :accessory
    t.string    :course
    t.string    :teacher
    t.string    :other
    t.datetime  :last_modified_at
    t.integer   :last_modified_by_id
  end
  
  create_table "school_contacts" do |t|
    t.integer   :school_id
    t.string    :name
    t.string    :role
    t.string    :telephone
    t.string    :email
    t.string    :qq
    t.datetime  :last_modified_at
    t.integer   :last_modified_by_id
  end
  
  create_table "school_locals" do |t|
    t.integer   :school_id
    t.string    :incoming_from
    t.string    :incoming_average
    
    t.integer   :ngo_support,     :limit => 1
    t.string    :ngo_name
    t.datetime  :ngo_start_at
    t.string    :ngo_contact
    t.string    :ngo_contact_via
    
    t.text      :advice
    t.text      :advice_html
    
    t.datetime  :last_modified_at
    t.integer   :last_modified_by_id
  end
    
  create_table "school_finders" do |t|
    t.integer   :school_id
    t.string    :name
    t.string    :email
    t.string    :qq
    t.string    :msn
    t.datetime  :survey_at
    t.datetime  :last_modified_at
    t.integer   :last_modified_by_id
  end
  
  create_table "visiteds" do |t|
    t.integer   :school_id
    t.integer   :user_id
    t.datetime  :visited_at
    t.integer   :status,    :limit => 1 # 1 => visited, 2 => interesting
    t.datetime  :created_at
  end
  
  create_table "tags" do |t|
    t.string    :name
  end
  
  create_table "taggings" do |t|
    t.integer   :tag_id
    t.integer   :taggable_id
    t.string    :taggable_type
    t.datetime  :created_at
  end
  add_index :taggings, :tag_id
  add_index :taggings, [:taggable_id, :taggable_type]
  
  # for CMS
  create_table "pages" do |t|
    t.string    :title,       :null => false
    t.string    :slug,        :null => false
    t.text      :body
    t.datetime  :created_at
    t.datetime  :updated_at
    t.datetime  :last_modified_at
    t.integer   :last_modified_by_id
  end
  
  create_table "shares" do |t|
    t.string    :title,       :null => false
    t.integer   :geo_id,      :null => false
    # paperclip
    t.string    :share_cover_file_name
    t.string    :share_cover_content_type
    t.string    :share_cover_file_size
    
    t.text      :body_html
    t.integer   :activity_id
    t.integer   :school_id
    
    t.integer   :user_id,     :null => false
    t.integer   :hits,        :null => false,     :default => 0
    t.integer   :comments_count, :null => false,  :default => 0
    t.boolean   :hidden,      :default => false
    t.datetime  :created_at
    t.datetime  :updated_at
    t.datetime  :last_modified_at
    t.integer   :last_modified_by_id
  end
  
  create_table "messages" do |t|
    t.integer   :author_id,     :null => false
    t.string    :subject
    t.text      :content
    t.text      :html_content
    t.boolean   :deleted,       :default => false
    t.datetime  :created_at
    t.datetime  :updated_at
    t.integer   :old_id
  end
  
  create_table  "message_copies" do |t|
    t.integer   :recipient_id,  :null => false
    t.integer   :message_id,    :null => false
    t.boolean   :unread,        :default => true
  end
  
  create_table "comments" do |t|
    t.integer   :user_id,       :null => false
    t.text      :body
    t.text      :body_html
    t.datetime  :created_at
    t.datetime  :updated_at
    t.string    :type
    t.string    :type_id
    t.integer   :old_id
  end
  
  create_table "groups" do |t|
    t.integer   :user_id,       :null => false
    t.integer   :geo_id,        :null => false
    t.string    :title,         :null => false
    t.text      :body_html
    t.datetime  :created_at
    t.datetime  :updated_at
    t.datetime  :deleted_at
  end
  
  create_table "memberships" do |t|
    t.integer   :user_id,     :null => false
    t.integer   :group_id,    :null => false
    t.datetime  :created_at
  end
  
end
