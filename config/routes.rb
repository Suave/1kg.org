ActionController::Routing::Routes.draw do |map|
  #map.connect '/data_migration', :controller => 'misc', :action => 'migration'
  map.root :controller => "misc", :action => "index"
  map.public_look "/public", :controller => "misc", :action => "public_look"
  map.custom_search "/cse",  :controller => "misc", :action => "custom_search"
  map.warmfund    "/warmfund", :controller => "misc", :action => "warmfund"
  map.warmfund    "/warmfund_container", :controller => "misc", :action => "warmfund_container"
  map.city   "city/:slug", :controller => "geos", :action => "city"
  map.cities "/cities", :controller => "misc", :action => "cities"
  map.my_city "/my_city", :controller => "misc", :action => "my_city"
  
  map.page "/misc/:slug", :controller => "misc", :action => "show_page"

  map.tag  "/tags/:tag", :controller => "tags", :action => "show"
  
  #market
  #map.market "/market",:controller => "market",:action => "index"

  #map.resources :users
  map.with_options :controller => "users" do |user|
    user.signup 'signup', :action => "new"
    user.activate 'activate/:activation_code', :action => "activate"
    user.setting 'setting', :action => "edit"
  end
  
  map.resource :session
  map.with_options :controller => "sessions" do |session|
    session.login 'login', :action => "new"
    session.logout 'logout', :action => "destroy"
    session.forget_password 'forget_password', :action => 'forget_password'
    session.reset_password 'reset_password', :action => 'reset_password'
  end
  
  map.resources :users, :member => {:submitted_activities => :get,
                                    :participated_activities => :get,
                                    :submitted_schools => :get,
                                    :visited_schools => :get,
                                    :interesting_schools => :get,
                                    :neighbors => :get,
                                    :shares => :get,
                                    :groups => :get,
                                    :group_topics => :get,
                                    :guides => :get,
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
  
  
  map.resources :schools, :member => {:lei => :get,
                                      :large_map => :get,
                                      :photos => :get,
                                      :validate => :put,
                                      :visited => :put,
                                      :interest => :put,
                                      :novisited => :put,
                                      :moderator => :get,
                                      :marked => :put,
                                      :manage => :put},
                          :collection => { :unconfirm => :get, 
                                           :archives => :get, 
                                           :cits => :get,
                                           :todo => :get,
                                           :comments => :get
                                          } do |school|
    school.resources :visits
    school.resources :guides, :member => {:vote => :post}
  end
  map.connect "/schools/date/:year/:month/:day", :controller => "schools",  
                                                 :action => "show_date", 
                                                 :requirment => { :year => /(19|20)\d\d/,             
                                                                  :month => /[01]?\d/,                
                                                                  :day => /[0-3]?\d/ 
                                                                },                      
                                                 :month => nil, :day => nil
  
  map.resources :activities, :member => { :join => :get, 
                                          :quit => :put, 
                                          :stick => :put, 
                                          :invite => :get,
                                          :send_invitation => :put
                                        },
                             :collection => {:ongoing => :get, :over => :get}


  map.resources :boards, :member =>     { :schools => :get }, 
                         :collection => { :public_issue => :get} do |board|
                           
    board.resources :topics, :member => { :stick => :put, :close => :put} do |topic|
      topic.resources :posts
    end
  end
  
  map.resources :comments
  
  map.resources :shares
  
  map.resources :searches
  
  map.resources :groups, :member => { :join => :get, 
                                      :quit => :put, 
                                      :new_topic => :get, 
                                      :manage => :get, 
                                      :moderator => :put,
                                      :invite => :get,
                                      :send_invitation => :put,
                                      :members => :get
                                    },
                          :collection => {:all => :get}
  
  map.resources :photos
  
  map.resources :bulletins
  
  map.admin '/admin', :controller => 'admin/misc', :action => 'index'
  map.namespace :admin do |admin|
    admin.resources :roles
    admin.resources :permissions
    admin.resources :users, :collection => {:search => :get}
    admin.resources :geos
    admin.resources :counties
    admin.resources :boards, :member => {:active => :put, :deactive => :put}
    admin.resources :moderators
    admin.resources :schools, :member => {:active => :put}, :collection => {:import => :get}
    admin.resources :pages
    admin.resources :groups
    admin.resources :stuff_types do |type|
      type.resources :bucks, :controller => "stuff_bucks"
    end
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
        dash.submit   'submit',   :action => "submit"
        dash.required   'required', :action => "required"
        dash.processing 'processing',  :action => "processing"
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
  end
  
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
