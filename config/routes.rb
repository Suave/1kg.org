ActionController::Routing::Routes.draw do |map|
  map.root :controller => "misc", :action => "index"

  # 用于公益积分
  map.receive_merchant_info "/gateway/receiveMerchantInfo", :controller => "gateway", :action => "receive_merchant_info"
  map.resources :donations, :member => {:commenting => :get, :comment => :put}, :collection => {:thanks => :get}
  map.resources :requirements, :member => {}  
  
  map.resources :co_donations, :member => {:feedback => :get} do |c|
    c.resources :sub_donations, :member => {:prove => :put,
                                            :admin_state => :put}
    c.resources :comments, :controller => 'comments', :requirements => {:commentable => 'CoDonation'}    
  end
 
  map.resources :requirements do |requirement|
    requirement.resources :comments, :controller => 'comments', :requirements => {:commentable => 'Requirement'}
  end
  
  map.public_look "/public", :controller => "misc", :action => "public_look"
  map.public_atom "/misc/public_look",:controller => "misc", :action => "public_look"
  map.page "/misc/:slug", :controller => "misc", :action => "show_page"

  map.needs_tag  "/tags/needs", :controller => "tags", :action => "needs"
  map.tag  "/tags/:tag", :controller => "tags", :action => "show"
  map.topics "/topics/total",:controller => "topics", :action => "total"

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
                                    :shares => :get,
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
                                        :all => :get },
                       :member     => { :schools => :get, 
                                        :schools_map => :get, 
                                        :shares => :get, 
                                        :users => :get }
                           
  map.connect '/geo_choice', :controller => 'geos_controller', :action => 'geo_choice'
  
  
  map.resources :schools, :member => {:large_map => :get,
                                      :photos => :get,
                                      :apply => :get,
                                      :shares => :get,
                                      :moderator => :get,
                                      :validate => :put,
                                      :visited => :put,
                                      :interest => :put,
                                      :wanna => :put,
                                      :setphoto => :put,
                                      :novisited => :put,
                                      :marked => :put,
                                      :manage => :put,
                                      :sent_apply => :post},
                          :collection => { :unconfirm => :get, 
                                           :archives => :get, 
                                           :cits => :get,
                                           :check => :get,
                                           :todo => :get,
                                           :comments => :get
                                          } do |school|
    school.resources :visits
    school.resources :requirements do |requirement|
      requirement.resources :comments, :controller => 'comments', :requirements => {:commentable => 'Requirement'}
    end
    
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
                             :collection => {:with_school => :get,:category => :get,:ongoing => :get, :over => :get} do |activity|
    activity.resources :comments, :controller => 'comments', :requirements => {:commentable => 'Activity'}
  end


  map.resources :boards, :member => { :schools => :get } do |board|
    board.resources :topics, :member => { :stick => :put, :close => :put} do |topic|
      topic.resources :posts
    end
  end
  
  map.resources :shares, :member => {:vote => :post} do |share|
    share.resources :comments, :controller => 'comments', :requirements => {:commentable => 'Share'}
  end
  
  map.resources :posts do |post|
    post.resources :comments, :controller => 'comments', :requirements => {:commentable => 'Post'}
  end
  
  map.resources :comments do |post|
    post.resources :comments, :controller => 'comments', :requirements => {:commentable => 'Comment'}
  end

  map.resources :bulletins do |bulletin|
    bulletin.resources :comments, :controller => 'comments', :requirements => {:commentable => 'Bulletin'}
  end
  
  map.resource :search
  
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
  
  map.resources :games, :member => {:versions => :get, :revert => :put}  do |game|
    game.resources :comments, :controller => 'comments', :requirements => {:commentable => 'Game'}
  end
  
  map.with_options :controller => 'games' do |games|
    games.category_games    '/games/category/:tag',     :action => "category"
    games.new_category_game '/games/category/:tag/new', :action => "new"
  end

  map.resources :requirement_types, :as => 'projects' do |project|
    project.resources :requirements
    project.resources :comments, :controller => 'comments', :requirements => {:commentable => 'RequirementType'}
  end
  
  map.admin '/admin', :controller => 'admin/misc', :action => 'index'
  map.namespace :admin do |admin|
    admin.resources :roles
    admin.resources :permissions
    admin.resources :users, :collection => {:search => :get}, :member => {:block => :put}
    admin.resources :geos
    admin.resources :counties
    admin.resources :boards, :member => {:active => :put, :deactive => :put}
    admin.resources :moderators
    admin.resources :schools, :member => {:active => :put}, :collection => {:import => :get, :merging => :get, :merge => :put}
    admin.resources :pages
    admin.resources :groups
    admin.resources :game_categories
    admin.resources :co_donations,:member => {:validate => :put, :cancel => :put}
    admin.resources :requirement_types, :member => {:validate => :put, :cancel => :put} do |type|
      type.resources :requirements, :member => {:approve => :put, :reject => :put}
    end
    admin.resources :vendors # 公益商品供应商，包括积分兑换商家
    admin.resources :bulletins
    
  end

  # 公益产品
  map.namespace :minisite do |site|
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
        dash.submit   'cards',    :action => "cards"
        dash.password '/password',:action => "password"
        dash.comment  '/comment', :action => "comment"
      end
    end
  end
  
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end