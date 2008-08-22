ActionController::Routing::Routes.draw do |map|
  map.root :controller => "misc", :action => "index"
  
  map.resources :users do |user|
    user.resources :visiteds
    user.resources :participations
    
    # submitted by the user
    user.resources :schools
    user.resources :activities
    
    user.resources :topics
  end
  
  map.setting "/settting", :controller => "profiles", :action => "edit"
  
  map.resources :schools do |school|
    school.resources :visits
    school.resources :photos
    school.resource  :space
  end
  
  map.resources :activities do |activity|
    activity.resources :participations
    activity.resources :photos
    activity.resource  :space
  end
  
  map.resources :spaces do |space|
    space.resources :topics do |topic|
      topic.resources :posts
    end
  end
  
  map.namespace :admin do |admin|
    admin.resources :regions
  end

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
