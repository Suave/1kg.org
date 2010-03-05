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

ActiveRecord::Schema.define(:version => 0) do

  create_table "activities", :force => true do |t|
    t.integer  "user_id",                             :null => false
    t.integer  "school_id"
    t.boolean  "done",             :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.string   "ref"
    t.integer  "category",                            :null => false
    t.string   "title",                               :null => false
    t.string   "location",                            :null => false
    t.integer  "departure_id",                        :null => false
    t.integer  "arrival_id",                          :null => false
    t.datetime "start_at"
    t.datetime "end_at"
    t.datetime "register_over_at"
    t.string   "expense_per_head"
    t.string   "expect_strength"
    t.text     "clean_html"
    t.text     "description_html"
    t.integer  "comments_count",   :default => 0
    t.integer  "participations_count", :default => 0
    t.integer  "shares_count", :default => 0
    t.integer  "old_id"
    t.integer  "main_photo_id"
    t.boolean  "sticky",           :default => false
  end

  create_table "activity_boards", :force => true do |t|
    t.integer "activity_id",      :null => false
    t.text    "description"
    t.text    "description_html"
  end

  create_table "areas", :force => true do |t|
    t.integer "parent_id"
    t.integer "lft"
    t.integer "rgt"
    t.string  "title"
    t.integer "zipcode"
  end

  create_table "boards", :force => true do |t|
    t.integer  "talkable_id",                        :null => false
    t.string   "talkable_type",                      :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.integer  "topics_count",        :default => 0
    t.datetime "last_modified_at"
    t.integer  "last_modified_by_id"
  end

  create_table "city_boards", :force => true do |t|
    t.integer "geo_id",           :null => false
    t.text    "description"
    t.text    "description_html"
  end

  create_table "comments", :force => true do |t|
    t.integer  "user_id",    :null => false
    t.text     "body"
    t.text     "body_html"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
    t.string   "type_id"
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.datetime "deleted_at"
  end

  create_table "counties", :force => true do |t|
    t.integer "geo_id"
    t.string  "name",    :null => false
    t.integer "zipcode"
  end

  create_table "geos", :force => true do |t|
    t.integer "parent_id"
    t.integer "lft",       :null => false
    t.integer "rgt",       :null => false
    t.string  "name",      :null => false
    t.integer "zipcode"
    t.string  "slug"
    t.string  "latitude"
    t.string  "longitude"
  end

  create_table "group_boards", :force => true do |t|
    t.integer "group_id", :null => false
  end

  create_table "groups", :force => true do |t|
    t.integer  "user_id",    :null => false
    t.integer  "geo_id",     :null => false
    t.string   "title",      :null => false
    t.text     "body_html"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.string   "avatar"
    t.string   "slug"
  end

  create_table "memberships", :force => true do |t|
    t.integer  "user_id",    :null => false
    t.integer  "group_id",   :null => false
    t.datetime "created_at"
  end

  create_table "message_copies", :force => true do |t|
    t.integer "recipient_id",                   :null => false
    t.integer "message_id",                     :null => false
    t.boolean "unread",       :default => true
  end

  create_table "messages", :force => true do |t|
    t.integer  "author_id",                       :null => false
    t.string   "subject"
    t.text     "content"
    t.text     "html_content"
    t.boolean  "deleted",      :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "neighborhoods", :force => true do |t|
    t.integer  "user_id",     :null => false
    t.integer  "neighbor_id", :null => false
    t.datetime "created_at"
  end

  create_table "pages", :force => true do |t|
    t.string   "title",               :null => false
    t.string   "slug",                :null => false
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "last_modified_at"
    t.integer  "last_modified_by_id"
  end

  create_table "participations", :force => true do |t|
    t.integer  "user_id"
    t.integer  "activity_id"
    t.datetime "created_at"
  end

  create_table "photos", :force => true do |t|
    t.integer  "parent_id"
    t.string   "content_type"
    t.string   "filename"
    t.string   "thumbnail"
    t.integer  "size"
    t.integer  "width"
    t.integer  "height"
    t.integer  "user_id"
    t.string   "title",            :null => false
    t.text     "description"
    t.text     "description_html"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.integer  "activity_id"
    t.integer  "school_id"
  end

  create_table "posts", :force => true do |t|
    t.integer  "topic_id",            :null => false
    t.integer  "user_id",             :null => false
    t.text     "body_html"
    t.text     "clean_html"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "last_modified_at"
    t.integer  "last_modified_by_id"
    t.datetime "deleted_at"
  end

  create_table "profiles", :force => true do |t|
    t.integer "user_id"
    t.string  "blog_url"
    t.text    "bio"
    t.text    "bio_html"
    t.string  "last_name"
    t.string  "first_name"
    t.integer "gender",     :limit => 1
    t.date    "birth"
    t.string  "phone"
    
    t.string   "twitter"
    t.string   "kaixin001"
    t.string   "renren"
    t.string   "douban"
    t.string   "qq"
    t.string   "msn"
    t.string   "skype"
    
    t.integer "privacy",    :limit => 1
  end

  create_table "public_boards", :force => true do |t|
    t.string  "title",            :limit => 100,                  :null => false
    t.text    "description"
    t.text    "description_html"
    t.integer "position",                        :default => 999, :null => false
    t.string  "slug"
    t.datetime "deleted_at"
  end

  create_table "roles", :force => true do |t|
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
    t.string   "identifier",  :limit => 100, :null => false
    t.string   "description"
  end

  add_index "roles", ["identifier"], :name => "index_roles_on_identifier"

  create_table "roles_static_permissions", :id => false, :force => true do |t|
    t.integer "role_id",              :null => false
    t.integer "static_permission_id", :null => false
  end

  add_index "roles_static_permissions", ["role_id", "static_permission_id"], :name => "role_id_and_static_permission_id", :unique => true

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer "role_id", :null => false
    t.integer "user_id", :null => false
  end

  add_index "roles_users", ["role_id", "user_id"], :name => "index_roles_users_on_role_id_and_user_id", :unique => true

  create_table "school_basics", :force => true do |t|
    t.integer  "school_id"
    t.string   "address"
    t.integer  "zipcode"
    t.string   "master"
    t.string   "telephone"
    t.string   "level_amount"
    t.string   "teacher_amount"
    t.string   "student_amount"
    t.string   "class_amount"
    t.integer  "has_library",    :limit => 1
    t.integer  "has_pc",         :limit => 1
    t.integer  "has_internet",   :limit => 1
    t.integer  "book_amount",                 :default => 0
    t.integer  "pc_amount",                   :default => 0
    t.string   "latitude"
    t.string   "longitude"
    t.integer  "marked_by_id"
    t.datetime "marked_at"
  end

  create_table "school_boards", :force => true do |t|
    t.integer "school_id",        :null => false
    t.text    "description"
    t.text    "description_html"
    t.datetime "deleted_at"
  end

  create_table "school_contacts", :force => true do |t|
    t.integer "school_id"
    t.string  "name"
    t.string  "role"
    t.string  "telephone"
    t.string  "email"
    t.string  "qq"
  end

  create_table "school_finders", :force => true do |t|
    t.integer  "school_id"
    t.string   "name"
    t.string   "email"
    t.string   "qq"
    t.string   "msn"
    t.string   "phone_number"
    t.text     "note"
    t.datetime "survey_at"
  end

  create_table "school_locals", :force => true do |t|
    t.integer  "school_id"
    t.string   "incoming_from"
    t.string   "incoming_average"
    t.integer  "ngo_support",      :limit => 1
    t.string   "ngo_name"
    t.string   "ngo_projects"
    t.datetime "ngo_start_at"
    t.string   "ngo_contact"
    t.string   "ngo_contact_via"
    t.text     "advice"
    t.text     "advice_html"
  end

  create_table "school_needs", :force => true do |t|
    t.integer "school_id"
    t.string  "urgency"
    t.string  "book"
    t.string  "stationary"
    t.string  "sport"
    t.string  "cloth"
    t.string  "accessory"
    t.string  "course"
    t.string  "teacher"
    t.string  "medicine"
    t.string  "hardware"
    t.string  "other"
  end

  create_table "school_snapshots", :force => true do |t|
    t.integer "school_id"
    t.integer "karma"
    t.date    "created_on"
  end

  create_table "school_traffics", :force => true do |t|
    t.integer "school_id"
    t.string  "sight"
    t.string  "transport"
    t.string  "duration"
    t.string  "charge"
    t.text    "description"
    t.text    "description_html"
  end
  
  create_table "school_guides", :force => true do |t|
    t.string  "title"
    t.text    "clean_html"
    t.text    "content"
    t.integer "user_id"
    t.integer "school_id"
    t.integer "hits", :default => 0
    t.integer  "comments_count",           :default => 0,     :null => false
    t.datetime "last_modified_at"
    t.integer  "last_modified_by_id"
    t.datetime "last_replied_at"
    t.integer  "last_replied_by_id"
    t.datetime "deleted_at"
    
    t.timestamps
  end

  create_table "schools", :force => true do |t|
    t.integer  "user_id"
    t.string   "ref"
    t.boolean  "validated",           :default => false
    t.boolean  "meta",                :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.integer  "category"
    t.integer  "geo_id"
    t.integer  "county_id"
    t.integer  "main_photo_id"
    t.string   "title",                                  :null => false
    t.datetime "last_modified_at"
    t.integer  "last_modified_by_id"
    t.datetime "validated_at"
    t.integer  "validated_by_id"
    t.integer  "hits",                :default => 0
    t.integer  "karma",               :default => 0
    t.integer  "last_month_karma",    :default => 0
  end

  create_table "shares", :force => true do |t|
    t.string   "title",                                       :null => false
    t.integer  "geo_id",                                      :null => false
    t.string   "share_cover_file_name"
    t.string   "share_cover_content_type"
    t.string   "share_cover_file_size"
    t.text     "body_html"
    t.text     "clean_html"
    t.integer  "activity_id"
    t.integer  "school_id"
    t.integer  "user_id",                                     :null => false
    t.integer  "hits",                     :default => 0,     :null => false
    t.integer  "comments_count",           :default => 0,     :null => false
    t.boolean  "hidden",                   :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "last_modified_at"
    t.integer  "last_modified_by_id"
    t.datetime "last_replied_at"
    t.datetime "deleted_at"    
    t.integer  "last_replied_by_id"
  end

  create_table "static_permissions", :force => true do |t|
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
    t.string   "identifier",  :limit => 100, :null => false
    t.string   "description"
  end

  add_index "static_permissions", ["identifier"], :name => "index_static_permissions_on_identifier"

  create_table "stuff_bucks", :force => true do |t|
    t.integer  "type_id",                          :null => false
    t.integer  "school_id",                        :null => false
    t.integer  "quantity",                         :null => false
    t.integer  "matched_count", :default => 0
    t.datetime "created_at"
    t.string   "status"
    t.text     "notes_html"
    t.text     "for_team_tip"
    t.boolean  "for_team",      :default => false
    t.boolean  "hidden",        :default => false
  end

  create_table "stuff_types", :force => true do |t|
    t.string   "slug",             :null => false
    t.string   "title",            :null => false
    t.text     "description_html"
    t.integer  "bucks_count",      :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "stuffs", :force => true do |t|
    t.string   "code",         :null => false
    t.integer  "type_id",      :null => false
    t.integer  "buck_id"
    t.integer  "user_id"
    t.integer  "school_id"
    t.datetime "matched_at"
    t.datetime "created_at"
    t.text     "comment_html"
    t.text     "comment"
    t.boolean  "auto_fill"
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type"], :name => "index_taggings_on_taggable_id_and_taggable_type"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "topics", :force => true do |t|
    t.integer  "board_id",                                              :null => false
    t.integer  "user_id",                                               :null => false
    t.string   "title",               :limit => 200,                    :null => false
    t.text     "clean_html"
    t.text     "body_html"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "last_replied_at"
    t.integer  "last_replied_by_id"
    t.datetime "last_modified_at"
    t.integer  "last_modified_by_id"
    t.datetime "deleted_at"
    t.boolean  "block",                              :default => false
    t.integer  "posts_count",                        :default => 0
    t.boolean  "sticky",                             :default => false
  end

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
    t.string   "ip"
    t.boolean  "email_notify",              :default => true
    
    t.integer  "posts_count"
    t.integer  "topics_count"
    t.integer  "shares_count"
    t.integer  "guides_count"
  end

  add_index "users", ["email", "state"], :name => "index_users_on_email_and_state"

  create_table "visiteds", :force => true do |t|
    t.integer  "school_id"
    t.integer  "user_id"
    t.datetime "visited_at"
    t.integer  "status",     :limit => 1
    t.datetime "created_at"
    t.datetime "wanna_at"
    t.string   "notes",      :limit => 42
    t.datetime "deleted_at"
  end

  create_table "searches", :force => true do |t|
    t.string  :q
    t.string  :title
    t.string  :city
    t.string  :address
    t.string  :need
    t.string  :kind, :default => 'school'
    t.integer :user_id
    t.string  :category
    t.string  :on
    t.string  :include_over
    t.timestamps
  end
  
  create_table :votes, :force => true do |t|
    t.column :vote, :boolean, :default => false
    t.column :created_at, :datetime, :null => false
    t.column :voteable_type, :string, :limit => 15,
      :default => "", :null => false
    t.column :voteable_id, :integer, :default => 0, :null => false
    t.column :user_id, :integer, :default => 0, :null => false
  end

  add_index :votes, ["user_id"], :name => "fk_votes_user"
  
  create_table :bulletins, :force => true do |t|
    t.string    "title"
    t.text      "body"
    t.string    "redirect_url"
    t.integer   "comments_count",   :default => 0 
    t.integer   "user_id"
    t.datetime  "created_at"
    t.datetime  "udpated_at"
  end
end
