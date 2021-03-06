ActionController::Routing::Routes.draw do |map|
  map.root :controller => "misc", :action => "index"
  # 用于公益积分
  map.receive_merchant_info "/gateway/receiveMerchantInfo", :controller => "gateway", :action => "receive_merchant_info"
  map.resources :donations, :member => {:commenting => :get, :comment => :put}, :collection => {:thanks => :get}
  map.resources :requirements, :member => {}  
  map.system_message "/admin/sent/by_system", :controller => "sent", :action => "by_system"
  
  map.resources :co_donations, :member => {:feedback => :get,:send_invitation => :put,:invite => :get},:collection => {:over => :get} do |c|
    c.resources :sub_donations, :member => {:prove => :put,
                                            :admin_state => :put}
    c.resources :comments, :controller => 'comments', :requirements => {:commentable => 'CoDonation'}    
  end
 
  map.resources :executions do |execution|
    execution.resources :comments, :controller => 'comments', :requirements => {:commentable => 'Execution'}
  end
  
  map.resources :villages,:member => {:join_research => :post,:main_photo => :get,:location => :get,:large_map => :get}
  
  
  map.public_look "/public", :controller => "misc", :action => "public_look"
  map.public_atom "/misc/public_look",:controller => "misc", :action => "public_look"
  map.page "/misc/:slug", :controller => "misc", :action => "show_page"
  map.search "/search", :controller => "search", :action => "show"

  map.needs_tag  "/tags/needs", :controller => "tags", :action => "needs"
  map.tag  "/tags/:tag", :controller => "tags", :action => "show"

  map.with_options :controller => "users" do |user|
    user.signup 'signup', :action => "new"
    user.activate 'activate/:activation_code', :action => "activate"
    user.setting 'setting', :action => "edit"
  end
  
  map.resource :session
  map.with_options :controller => "sessions" do |session|
    session.login 'login', :action => "new"
    session.ajax_login 'ajax_login', :action => "ajax_login"
    session.logout 'logout', :action => "destroy"
    session.forget_password 'forget_password', :action => 'forget_password'
    session.reset_password 'reset_password', :action => 'reset_password'
  end
  
  map.resources :users, :member => {:submitted_activities => :get,
                                    :participated_activities => :get,
                                    :submitted_schools => :get,
                                    :friends => :get,
                                    :topics => :get,
                                    :groups => :get,
                                    :group_topics => :get,
                                    :visited => :get,
                                    :envoy => :get,
                                    :submitted_topics => :get,
                                    :participated_topics => :get},
                        :has_many => [:sent] do |user|
    user.resources :received, :member => {:reply => :get}, :collection => {:destroy_all => :delete}
    user.resources :neighbors
  end
    
  map.resources :geos, :collection => { :search => :get, 
                                       },
                       :member     => { :schools => :get, 
                                        :topics => :get, 
                                        :users => :get }
                           
  map.connect '/geo_choice', :controller => 'geos_controller', :action => 'geo_choice'
  
  
  map.resources :schools, :member => {:large_map => :get,
                                      :photos => :get,
                                      :apply => :get,
                                      :topics => :get,
                                      :managers => :get,
                                      :validate => :put,
                                      :visited => :put,
                                      :interest => :put,
                                      :wanna => :put,
                                      :setphoto => :put,
                                      :followers => :get,
                                      :novisited => :put,
                                      :intro =>  :get,
                                      :marked => :put,
                                      :manage => :put,
                                      :sent_apply => :post},
                          :collection => { :unconfirm => :get, 
                                           :archives => :get, 
                                           :cits => :get,
                                           :check => :get,
                                           :total_topics => :get,
                                           :comments => :get
                                          } do |school|
    school.resources :visits
    
  end
  map.connect "/schools/date/:year/:month/:day", :controller => "schools",
                                                 :action => "show_date", 
                                                 :requirment => { :year => /(19|20)\d\d/,
                                                                  :month => /[01]?\d/,
                                                                  :day => /[0-3]?\d/
                                                                },
                                                 :month => nil, :day => nil
  
  map.resources :activities, :member => { :join => :get,
                                          :mainphoto => :get,
                                          :mainphoto_create => :post,
                                          :quit => :put, 
                                          :stick => :put,
                                          :setphoto => :put,
                                          :invite => :get,
                                          :send_invitation => :put
                                        },
                             :collection => {:with_school => :get,
                                             :category => :get,
                                             :ongoing => :get,
                                             :over => :get,
                                             :total_topics => :get} do |activity|
    activity.resources :comments, :controller => 'comments', :requirements => {:commentable => 'Activity'}
  end


  map.resources :follows
  map.resources :managements
  map.resources :votes
  map.resources :themes
  map.resources :topics, :member => { :vote => :post, :stick => :put, :close => :put} 
  
  map.resources :posts do |post|
    post.resources :comments, :controller => 'comments', :requirements => {:commentable => 'Post'}
  end
  
  map.resources :comments do |post|
    post.resources :comments, :controller => 'comments', :requirements => {:commentable => 'Comment'}
  end

  map.resources :bulletins do |bulletin|
    bulletin.resources :comments, :controller => 'comments', :requirements => {:commentable => 'Bulletin'}
  end
  
  
  map.resources :groups, :member => { :join => :get, 
                                      :quit => :put, 
                                      :new_topic => :get, 
                                      :manage => :get, 
                                      :moderator => :put,
                                      :invite => :get,
                                      :send_invitation => :put,
                                      :members => :get
                                    },
                            :collection => {:all => :get,
                            :participated => :get,
                            :submitted => :get}
  
  map.resources :photos
  map.resources :boxes, :collection => {:apply => :get,
    :feedback => :get,
    :topics => :get,
    :photos => :get,
    :submit => :post,
    :new_photo => :get,
    :new_topic => :get,
    :execution => :get,
    :executions => :get} do |box|
    box.resources :comments, :controller => 'comments', :requirements => {:commentable => 'Box'}
  end

  map.resources :games, :member => {:versions => :get, :revert => :put}  do |game|
    game.resources :comments, :controller => 'comments', :requirements => {:commentable => 'Game'}
  end
  
  map.with_options :controller => 'games' do |games|
    games.category_games    '/games/category/:tag',     :action => "category"
    games.new_category_game '/games/category/:tag/new', :action => "new"
  end
  
  map.resources :teams,:member => { :managers => :get,
                                    :search_user => :get,
                                    :add => :post,
                                    :leave => :delete,
                                    :new_activity => :get,
                                    :create_activity => :post,
                                    :follow => :post,
                                    :unfollow => :delete,
                                    :large_map => :get,
                                    :managers  => :get
                                  }

  map.resources :projects, :member => {:manage => :get,:large_map => :get,:topics => :get ,:photos => :get} do |project|
    project.resources :executions, :member => {:info_window => :get,:validate => :put,:refuse => :put,:finish => :put,:refuse_letter => :get,:feedback => :get} do |execution|
      execution.resources :comments, :controller => 'comments', :requirements => {:commentable => 'Execution'}
    end
    project.resources :comments, :controller => 'comments', :requirements => {:commentable => 'Project'}
  end
  
  map.admin '/admin', :controller => 'admin/misc', :action => 'index'
  map.namespace :admin do |admin|
    admin.resources :roles
    admin.resources :boxes
    admin.resources :bringings, :member => {:validate => :put, :refuse => :put}
    admin.resources :permissions
    admin.resources :users, :collection => {:search => :get,:reset_password => :post}, :member => {:block => :put}
    admin.resources :geos
    admin.resources :counties
    admin.resources :boards, :member => {:active => :put, :deactive => :put}
    admin.resources :moderators
    admin.resources :schools, :member => {:active => :put}, :collection => {:import => :get, :merging => :get, :merge => :put}
    admin.resources :pages
    admin.resources :groups
    admin.resources :game_categories
    admin.resources :co_donations,:member => {:validate => :put, :cancel => :put}
    admin.resources :teams,:member => {:validate => :put, :cancel => :put}
    admin.resources :requirement_types, :member => {:validate => :put, :cancel => :put} do |type|
      type.resources :requirements, :member => {:approve => :put, :reject => :put}
    end
    admin.resources :vendors # 公益商品供应商，包括积分兑换商家
    admin.resources :bulletins
    admin.resources :projects,:member => {:validate => :put, :refuse_letter => :get,:refuse => :put}
  end

  # 专题页面
  map.namespace :minisite do |site|
    map.weixingfu "/minisite/weixingfu", :controller => "/minisite/weixingfu", :action => "index"
    map.mangexingdong "/minisite/mangexingdong", :controller => "/minisite/mangexingdong", :action => "index"
    map.mangexingdong_poster "/minisite/mangexingdong/poster", :controller => "/minisite/mangexingdong", :action => "poster"
    site.namespace :postcard do |postcard|
      postcard.with_options :controller => "dashboard" do |dash|
        dash.index    '',         :action => "index"
        dash.password 'password', :action => "password"
        dash.give     'give/:id', :action => "give"
        dash.comment  'comment/:id', :action => "comment"
        dash.messages 'messages', :action => "messages"
        dash.donors   'donors/:id', :action => "donors"
        dash.love_message 'love_message', :action => "love_message"
      end
    end
    
    site.namespace :mooncake do |mooncake|
      mooncake.with_options :controller => "dashboard" do |dash|
        dash.index    '',         :action => "index"
        dash.password '/password',:action => "password"
        dash.comment  '/comment', :action => "comment"
        dash.love_message 'love_message', :action => "love_message"
        dash.messages 'messages', :action => "messages"
        dash.donors   'donors/:id', :action => "donors"
      end
    end
    
    site.namespace :lightenschool do |lightenschool|
      lightenschool.with_options :controller => "dashboard" do |dash|
        dash.index    '',         :action => "index"
        #dash.submit   'submit',   :action => "submit"
        dash.required   'required', :action => "required"
        #dash.processing 'processing',  :action => "processing"
        dash.processing 'winners',  :action => "winners"
      end
    end
    
    site.namespace :kuailebox do |kuailebox|
      kuailebox.with_options :controller => "dashboard" do |dash|
        dash.index    '',         :action => "index"
      end
    end
    
    site.namespace :cnbloggercon09 do |cnbloggercon09|
      cnbloggercon09.with_options :controller => "dashboard" do |dash|
        dash.index    '',         :action => "index"
      end
    end
    
    site.namespace :festcard09 do |festcard09|
      festcard09.with_options :controller => "dashboard" do |dash|
        dash.index    '',         :action => "index"
        dash.cards   '/cards',    :action => "cards"
        dash.password '/password',:action => "password"
        dash.comment  '/comment', :action => "comment"
      end
    end
    
    site.namespace :musicclassroom do |musicclassroom|
      musicclassroom.with_options :controller => "dashboard" do |dash|
        dash.index    '',         :action => "index"
      end
    end
  end
  
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
