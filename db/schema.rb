ActiveRecord::Schema.define do
  create_table :sessions, :force => true do |t|
    t.string :session_id, :null => false
    t.text   :data
    t.timestamps
  end
  add_index :sessions, :session_id, :name => "sessions_session_id_index"
  add_index :sessions, :updated_at, :name => "sessions_updated_at_index"

  create_table :users, :force => true do |t|
    t.string   :login
    t.string   :email
    t.string   :crypted_password, :limit => 40
    t.string   :salt,             :limit => 40
    t.timestamps
    t.string   :remember_token
    t.datetime :remember_token_expires_at
    t.string   :activation_code,  :limit => 40
    t.datetime :activated_at
    t.string   :avatar_url
    t.string   :admin
    t.string   :from # record which page does user sign up from
  end
  add_index :users, :email, :name => "users_email_index"
  add_index :users, :admin, :name => "users_admin_index"
  
  create_table :profiles, :force => true do |t|
    t.integer :user_id
    t.string  :blog_url
    t.text    :bio
    t.text    :bio_html
    t.string  :last_name
    t.string  :first_name
    t.integer :gender
    t.date    :birth
    t.string  :phone
    t.string  :qq
    t.string  :msn
    t.string  :gtalk
    t.integer :region_id
    t.integer :privacy
    t.boolean :identified, :default => false
    t.timestamps
  end
  add_index :profiles, :user_id, :name => "profiles_user_id_index"
  
  create_table :relationships, :force => true do |t|
    t.integer :user_id
    t.integer :neighbor_id
    t.datetime :created_at
  end
  add_index :relationships, :user_id, :name => "relationships_user_id_index"
  add_index :relationships, :neighbor_id, :name => "relationships_neighbor_id_index"
  
  create_table :messages, :force => true do |t|
    t.integer  :sender_id
    t.integer  :receiver_id
    t.string   :title
    t.text     :content
    t.text     :content_html
    t.boolean  :read, :default => false
    t.datetime :created_at
  end
  add_index :messages, :sender_id, :name => "message_sender_id_index"
  add_index :messages, :receiver_id, :name => "message_receiver_id_index"
  
  create_table :regions, :force => true do |t|
    t.integer   :parent_id
    t.integer   :lft
    t.integer   :rgt
    t.string    :title
  end
  
  create_table :activities, :force => true do |t|
    t.integer    :user_id
    t.string     :title
    t.integer    :category
    t.datetime   :start_at
    t.datetime   :end_at
    t.integer    :area_id
    t.string     :location
    t.string     :contact
    t.text       :content
    t.text       :content_html
    t.integer    :school_id
    # PENDING: submitor upload a photo, but only record the permalink in this column
    t.string     :photo_url
    t.boolean    :over, :default => false
    t.boolean    :hidden, :default => false
    t.string     :from # record which page does the activity has been submitted from
  end
  add_index :activities, :user_id, :name => "activitys_user_id_index"
  add_index :activities, :school_id, :name => "activitys_school_id_index"
  
  create_table :participations, :force => true do |t|
    t.integer   :activity_id
    t.integer   :user_id
    t.string    :phone
    t.string    :qq
    t.string    :msn
    t.string    :note
    t.datetime  :created_at
  end
  add_index :participations, :activity_id, :name => "participations_activity_id_index"
  add_index :participations, :user_id, :name => "paticipations_user_id_index"
  
  create_table :schools, :force => true do |t|
    t.integer   :user_id
    t.string    :title # school name
          
    # 单独用一个 demand 模型？         
    t.string    :urgency_need # PENDING: 
    t.string    :books_need
    t.string    :stationaries_need
    t.string    :sports_need
    t.string    :clothes_need
    t.string    :accessories_need
    t.string    :classes_need
    t.string    :teachers_need
    t.string    :others_need
    
    # 用一个 has_many :photos 就行了
    # t.string    :photo_url # link from schools' photos
    
    t.boolean   :validated, :default => false
    t.string    :validated_notes
    t.boolean   :hidden,    :default => false
    t.boolean   :meta,      :default => false
    t.string    :from
    t.timestamps
  end  
  add_index :schools, :area_id, :name => "schools_area_id_index"
  add_index :schools, :user_id, :name => "schools_user_id_index"
  
  create_table :school_infomations, :force => true do |t|
    t.integer   :school_id
    t.integer   :region_id
    t.integer   :type # 类型：小学、中学、板房？
    t.string    :address
    t.string    :zipcode
    t.string    :master # schoolmaster's name
    t.string    :telephone # school telephone number
    
    # 联系人信息考虑用单独模型
    t.string    :contact_name
    t.string    :contact_role
    t.string    :contact_telephone
    t.string    :contact_email
    
    t.string    :length_of_schooling # 学制
    t.string    :teacher_amount
    t.string    :class_amount
    t.string    :student_amount
    t.integer   :has_library, :limit => 1
    t.integer   :has_pc,      :limit => 1
    t.integer   :has_internet,:limit => 1
    t.integer   :book_amount
    t.integer   :pc_amount
    t.string    :incoming_from # PENDING: remove?
    t.integer   :incoming_average, :limit => 1 # PENDING: remove?
    
    # 其他组织支持考虑用单独模型
    t.integer   :ngo_support,      :limit => 1
    t.string    :ngo_name
    t.date      :ngo_start_at
    t.string    :ngo_contact_name
    t.string    :ngo_contact_via
    
    t.string    :traffic_sights
    t.string    :traffic_type
    t.string    :traffic_duration
    t.text      :traffic_content
    t.text      :traffic_content_html
    t.string    :traffic_charge
    
    # 发现提交人考虑用单独模型
    t.string    :finder_name
    t.string    :finder_qq
    t.string    :finder_msn
    t.string    :finder_email
    t.date      :fidner_survey_at
    t.text      :advice
    t.text      :advice_html
    
    t.timestamps
  end
  
  # 统一用角色权限做权控
  # create_table :school_moderators, :force => true do |t|
  #   t.integer   :school_id
  #   t.integer   :user_id
  #   t.string    :type # school moderator or school service group member
  #   t.timestamps
  # end
  
  create_table :visits, :force => true do |t|
    t.integer   :school_id
    t.integer   :user_id
    t.datetime  :visited_at
    t.string    :bring # PENDING: what's replationship between bring and schools' need
    t.string    :play # PENDING: how to tag? user should submitor game videos what they played
    t.text      :note
    t.text      :note_html
    t.timestamps
  end
  
  create_table :taggings, :force => true do |t|
    t.integer   :tag_id
    t.integer   :taggable_id
    t.string    :taggable_type
    t.datetime  :created_at
  end
  add_index :taggings, :tag_id, :name => "taggings_tag_id_index"
  add_index :taggings, [:taggable_id, :taggable_type], :name => "taggings_taggable_id_and_taggable_type_index"

  create_table :tags, :force => true do |t|
    t.string :name
  end
  
  create_table :photos, :force => true do |t|
    # for attachment_fu
    t.integer   :parent_id
    t.string    :content_type
    t.string    :filename
    t.string    :thumbnail
    t.integer   :size
    t.integer   :width
    t.integer   :height
    
    t.integer   :user_id
    t.integer   :school_id
    t.integer   :activity_id
    t.boolean   :hidden, :default => false
    t.string    :title
    t.text      :content
    t.text      :content_html
    t.timestamps
  end
  add_index :photos, :user_id, :name => "photos_user_id_index"
  add_index :photos, :school_id, :name => "photos_school_id_index"
  add_index :photos, :activity_id, :name => "photos_activity_id_index"
  
  create_table :spaces, :force => true do |t|
    t.string    :spacable_type
    t.integer   :spacable_id
    t.integer   :user_id
    t.string    :title
    t.text      :content
    t.text      :content_html
    t.string    :photo_url
    t.integer   :topics_count, :default => 0
    t.integer   :posts_count,  :default => 0
    t.boolean   :hidden,       :default => false
    t.integer   :position,     :default => 999
    t.timestamps
  end
  
  # 统一用角色权限做权控
  # create_table :moderators, :force => true do |t|
  #   t.integer   :space_id
  #   t.integer   :user_id
  #   t.datetime  :created_at
  # end
  # add_index :moderators, :space_id, :name => "moderators_space_id_index"
  
  create_table :topics, :force => true do |t|
    t.integer   :user_id
    t.integer   :space_id
    t.string    :title
    t.text      :content
    t.text      :content_html
    t.boolean   :sticky,      :default => false
    t.boolean   :blocked,     :default => false
    t.integer   :hits,        :default => 0
    t.integer   :posts_count, :default => 0
    t.timestamps
    t.datetime  :replied_at
    t.integer   :replied_by
  end
  add_index :topics, :user_id, :name => "topics_user_id_index"
  add_index :topics, :space_id, :name => "topics_space_id_index"
  
  create_table :posts, :force => true do |t|
    t.integer   :space_id
    t.integer   :topic_id
    t.integer   :user_id
    t.text      :content
    t.text      :content_html
    t.timestamps
  end
  add_index :posts, :topic_id, :name => "posts_topic_id_index"
  add_index :posts, :user_id, :name => "posts_user_id_index"
  
  create_table :groups, :force => true do |t|
    t.integer   :school_id
    t.integer   :user_id
    t.datetime  :created_at
  end
  add_index :groups, :school_id, :name => "service_groups_school_id_index"
    
end