ActionController::Routing::Routes.draw do |map|
  #map.connect '/data_migration', :controller => 'misc', :action => 'migration'
  map.root :controller => "misc", :action => "index"
  map.public_look "/public", :controller => "misc", :action => "public_look"
  map.cities "/cities", :controller => "misc", :action => "cities"
  #map.city   "/city/:id", :controller => "misc", :action => "city"
  map.my_city "/my_city", :controller => "misc", :action => "my_city"
  
  map.page "/misc/:slug", :controller => "misc", :action => "show_page"
  
  map.resources :users
  map.with_options :controller => "users" do |user|
    user.signup 'signup', :action => "new"
    user.activate 'activate/:activation_code', :action => "activate"
    user.setting 'setting', :action => "edit"
  end
  
  map.resource :session
  map.with_options :controller => "sessions" do |session|
    session.login 'login', :action => "new"
    session.logout 'logout', :action => "destroy"
  end
  
  
  
  map.resources :users, :member => {:submitted_activities => :get,
                                    :participated_activities => :get,
                                    :submitted_schools => :get,
                                    :visited_schools => :get,
                                    :interesting_schools => :get,
                                    :shares => :get},
                        :has_many => [:sent] do |user|
    user.resources :received, :member => {:reply => :get}
    user.resources :neighbors
  end
    
  map.resources :geos, :collection => {:search => :get, 
                                       :all => :get},
                           :member => {:schools => :get}
                           
  map.connect '/geo_choice', :controller => 'geos_controller', :action => 'geo_choice'
  
  
  map.resources :schools, :member => {:info => :get, 
                                      :validate => :put,
                                      :visited => :put,
                                      :interest => :put,
                                      :novisited => :put},
                          :collection => {:all => :get, :unconfirm => :get, :archives => :get, :cits => :get} do |school|
    school.resources :visits
  end
  map.connect "/schools/date/:year/:month/:day", :controller => "schools",  
                                                 :action => "show_date", 
                                                 :requirment => { :year => /(19|20)\d\d/,             
                                                                  :month => /[01]?\d/,                
                                                                  :day => /[0-3]?\d/ 
                                                                },                      
                                                 :month => nil, :day => nil
  
  map.resources :activities, :member => {:join => :put, :quit => :put, :stick => :put},
                             :collection => {:ongoing => :get, :over => :get}

  map.resources :boards, :member => {:schools => :get, :users => :get}, :collection => {:public_issue => :get} do |board|
    board.resources :topics, :member => {:stick => :put, :close => :put} do |topic|
      topic.resources :posts
    end
  end
  
  map.resources :comments
  
  map.resources :shares
  
  map.resources :groups, :member => {:join => :put, :quit => :put, :new_topic => :get, :manage => :get, :moderator => :put}
  
  map.admin '/admin', :controller => 'admin/misc', :action => 'index'
  map.namespace :admin do |admin|
    admin.resources :roles
    admin.resources :permissions
    admin.resources :users, :collection => {:search => :get}
    admin.resources :geos
    admin.resources :counties
    admin.resources :boards, :member => {:active => :put, :deactive => :put}
    admin.resources :moderators
    admin.resources :schools, :member => {:undelete => :put}
    admin.resources :pages
    admin.resources :groups
  end

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
