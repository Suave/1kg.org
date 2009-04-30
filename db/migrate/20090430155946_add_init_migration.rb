class AddInitMigration < ActiveRecord::Migration
  def self.up
    create_table "activities", :force => true do |t|
      t.integer  "user_id",                             :null => false
      t.integer  "school_id"
      t.boolean  "done",             :default => false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.datetime "deleted_at"
      t.string   "ref"
      t.integer  "category",                            :null => false
      t.string   "title",            :default => "",    :null => false
      t.string   "location",         :default => "",    :null => false
      t.integer  "departure_id",                        :null => false
      t.integer  "arrival_id",                          :null => false
      t.datetime "start_at"
      t.datetime "end_at"
      t.datetime "register_over_at"
      t.string   "expense_per_head"
      t.string   "expect_strength"
      t.text     "description"
      t.text     "description_html"
      t.integer  "comments_count",   :default => 0
      t.integer  "old_id"
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
      t.integer  "talkable_id",                         :null => false
      t.string   "talkable_type",       :default => "", :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.datetime "deleted_at"
      t.integer  "topics_count",        :default => 0
      t.datetime "last_modified_at"
      t.integer  "last_modified_by_id"
      t.integer  "old_id"
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
      t.integer  "old_id"
    end

    create_table "counties", :force => true do |t|
      t.integer "geo_id"
      t.string  "name",    :default => "", :null => false
      t.integer "zipcode"
      t.integer "old_id"
    end

    create_table "geos", :force => true do |t|
      t.integer "parent_id"
      t.integer "lft",                       :null => false
      t.integer "rgt",                       :null => false
      t.string  "name",      :default => "", :null => false
      t.integer "zipcode"
      t.integer "old_id"
    end

    create_table "group_boards", :force => true do |t|
      t.integer "group_id", :null => false
    end

    create_table "groups", :force => true do |t|
      t.integer  "user_id",                    :null => false
      t.integer  "geo_id",                     :null => false
      t.string   "title",      :default => "", :null => false
      t.text     "body_html"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.datetime "deleted_at"
      t.string   "avatar"
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
      t.integer  "old_id"
    end

    create_table "neighborhoods", :force => true do |t|
      t.integer  "user_id",     :null => false
      t.integer  "neighbor_id", :null => false
      t.datetime "created_at"
      t.integer  "old_id"
    end

    create_table "pages", :force => true do |t|
      t.string   "title",               :default => "", :null => false
      t.string   "slug",                :default => "", :null => false
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
      t.string   "title",            :default => "", :null => false
      t.text     "description"
      t.text     "description_html"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.datetime "deleted_at"
      t.integer  "activity_id"
      t.integer  "school_id"
    end

    create_table "pictures", :force => true do |t|
      t.integer  "parent_id"
      t.string   "content_type"
      t.string   "filename"
      t.string   "thumbnail"
      t.integer  "size"
      t.integer  "width"
      t.integer  "height"
      t.integer  "user_id"
      t.string   "title",            :default => "", :null => false
      t.text     "description"
      t.text     "description_html"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "event_id"
      t.integer  "school_id"
    end

    create_table "posts", :force => true do |t|
      t.integer  "topic_id",            :null => false
      t.integer  "user_id",             :null => false
      t.text     "body"
      t.text     "body_html"
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
      t.integer "privacy",    :limit => 1
    end

    create_table "public_boards", :force => true do |t|
      t.string  "title",            :limit => 100, :default => "",  :null => false
      t.text    "description"
      t.text    "description_html"
      t.integer "position",                        :default => 999, :null => false
      t.string  "slug"
    end

    create_table "roles", :force => true do |t|
      t.datetime "created_at",                                 :null => false
      t.datetime "updated_at",                                 :null => false
      t.string   "identifier",  :limit => 100, :default => "", :null => false
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
      t.integer  "has_library",         :limit => 1
      t.integer  "has_pc",              :limit => 1
      t.integer  "has_internet",        :limit => 1
      t.integer  "book_amount",                      :default => 0
      t.integer  "pc_amount",                        :default => 0
      t.datetime "last_modified_at"
      t.integer  "last_modified_by_id"
    end

    create_table "school_boards", :force => true do |t|
      t.integer "school_id",        :null => false
      t.text    "description"
      t.text    "description_html"
    end

    create_table "school_contacts", :force => true do |t|
      t.integer  "school_id"
      t.string   "name"
      t.string   "role"
      t.string   "telephone"
      t.string   "email"
      t.string   "qq"
      t.datetime "last_modified_at"
      t.integer  "last_modified_by_id"
    end

    create_table "school_finders", :force => true do |t|
      t.integer  "school_id"
      t.string   "name"
      t.string   "email"
      t.string   "qq"
      t.string   "msn"
      t.datetime "survey_at"
      t.datetime "last_modified_at"
      t.integer  "last_modified_by_id"
    end

    create_table "school_locals", :force => true do |t|
      t.integer  "school_id"
      t.string   "incoming_from"
      t.string   "incoming_average"
      t.integer  "ngo_support",         :limit => 1
      t.string   "ngo_name"
      t.datetime "ngo_start_at"
      t.string   "ngo_contact"
      t.string   "ngo_contact_via"
      t.text     "advice"
      t.text     "advice_html"
      t.datetime "last_modified_at"
      t.integer  "last_modified_by_id"
    end

    create_table "school_needs", :force => true do |t|
      t.integer  "school_id"
      t.string   "urgency"
      t.string   "book"
      t.string   "stationary"
      t.string   "sport"
      t.string   "cloth"
      t.string   "accessory"
      t.string   "course"
      t.string   "teacher"
      t.string   "other"
      t.datetime "last_modified_at"
      t.integer  "last_modified_by_id"
    end

    create_table "school_traffics", :force => true do |t|
      t.integer  "school_id"
      t.string   "sight"
      t.string   "transport"
      t.string   "duration"
      t.string   "charge"
      t.text     "description"
      t.text     "description_html"
      t.datetime "last_modified_at"
      t.integer  "last_modified_by_id"
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
      t.string   "title",               :default => "",    :null => false
      t.datetime "last_modified_at"
      t.integer  "last_modified_by_id"
      t.integer  "old_id"
    end

    create_table "shares", :force => true do |t|
      t.string   "title",                    :default => "",    :null => false
      t.integer  "geo_id",                                      :null => false
      t.string   "share_cover_file_name"
      t.string   "share_cover_content_type"
      t.string   "share_cover_file_size"
      t.text     "body_html"
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
      t.integer  "last_replied_by_id"
    end

    create_table "static_permissions", :force => true do |t|
      t.datetime "created_at",                                 :null => false
      t.datetime "updated_at",                                 :null => false
      t.string   "identifier",  :limit => 100, :default => "", :null => false
      t.string   "description"
    end

    add_index "static_permissions", ["identifier"], :name => "index_static_permissions_on_identifier"

    create_table "stuff_bucks", :force => true do |t|
      t.integer  "type_id",                      :null => false
      t.integer  "school_id",                    :null => false
      t.integer  "quantity",                     :null => false
      t.integer  "matched_count", :default => 0
      t.datetime "created_at"
      t.string   "status"
      t.text     "notes_html"
    end

    create_table "stuff_types", :force => true do |t|
      t.string   "slug",             :default => "", :null => false
      t.string   "title",            :default => "", :null => false
      t.text     "description_html"
      t.datetime "created_at"
    end

    create_table "stuffs", :force => true do |t|
      t.string   "code",       :default => "", :null => false
      t.integer  "type_id",                    :null => false
      t.integer  "buck_id",                    :null => false
      t.integer  "user_id"
      t.integer  "school_id"
      t.datetime "matched_at"
      t.datetime "created_at"
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
      t.string   "title",               :limit => 200, :default => "",    :null => false
      t.text     "body"
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

    add_index "users", ["email", "state"], :name => "index_users_on_email_and_state"

    create_table "visiteds", :force => true do |t|
      t.integer  "school_id"
      t.integer  "user_id"
      t.datetime "visited_at"
      t.integer  "status",     :limit => 1
      t.datetime "created_at"
    end
  end

  def self.down
    drop_table "activities"
    drop_table "activity_boards"
    drop_table "areas"
    drop_table "boards"
    drop_table "city_boards"
    drop_table "comments"
    drop_table "counties"
    drop_table "geos"
    drop_table "group_boards"
    drop_table "groups"
    drop_table "memberships"
    drop_table "message_copies"
    drop_table "messages"
    drop_table "neighborhoods"
    drop_table "pages"
    drop_table "participations"
    drop_table "photos"
    drop_table "pictures"
    drop_table "posts"
    drop_table "profiles"
    drop_table "public_boards"
    drop_table "roles"
    drop_index "roles", ["identifier"], :name => "index_roles_on_identifier"
    drop_table "roles_static_permissions", :id => false
    drop_index "roles_static_permissions", ["role_id", "static_permission_id"], :name => "role_id_and_static_permission_id", :unique => true
    drop_table "roles_users", :id => false
    drop_index "roles_users", ["role_id", "user_id"], :name => "index_roles_users_on_role_id_and_user_id", :unique => true
    drop_table "school_basics"
    drop_table "school_boards"
    drop_table "school_contacts"
    drop_table "school_finders"
    drop_table "school_locals"
    drop_table "school_needs"
    drop_table "school_traffics"
    drop_table "schools"
    drop_table "shares"
    drop_table "static_permissions"
    drop_index "static_permissions", ["identifier"], :name => "index_static_permissions_on_identifier"
    drop_table "stuff_bucks"
    drop_table "stuff_types"
    drop_table "stuffs"
    drop_table "taggings"
    drop_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
    drop_index "taggings", ["taggable_id", "taggable_type"], :name => "index_taggings_on_taggable_id_and_taggable_type"
    drop_table "tags"
    drop_table "topics"
    drop_table "users"
    drop_index "users", ["email", "state"], :name => "index_users_on_email_and_state"
    drop_table "visiteds"
  end
end
