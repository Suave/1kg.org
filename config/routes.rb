Onekg::Application.routes.draw do 
  root :to  => "misc#index"
  match 'signup' => 'users#new', :as => :signup
  match 'register' => 'users#create', :as => :register
  match 'setting' => 'users#edit', :as => :setting
  match 'login' => 'sessions#new', :as => :login
  match 'logout' => 'sessions#destroy', :as => :logout
  match 'search' => 'search#show', :as => :search
  match 'reset_password' => 'sessions#reset_password',:as => :reset_password 
  match 'forget_password' => 'sessions#forget_password',:as => :forget_password 
  match "/sent/by_system" => "sent#by_system"

  resources :executions
  resources :projects
  resources :messages
  resources :follows
  resources :managements
  resources :votes
  resources :themes
  resources :photos
  resources :tags
  resources :topics
  resources :comments
  resources :bulletins
  resource  :session
  
  resources :users do
    member do 
      get :submitted_activities
      get :participated_activities
      get :submitted_schools
      get :friends
      get :topics
      get :groups
      get :group_topics
      get :envoy
      get :submitted_topics
      get :participated_topics
    end
    resources :received, :member => {:reply => :get}, :collection => {:destroy_all => :delete}
  end
    
  resources :geos do
     get :search,:on => :collection
     get :schools,:on => :member
     get :users,:on => :member
  end
                           
  resources :schools do 
    member do 
      get :large_map
      get :photos
      get :apply
      get :topics
      get :managers
      get :validate
      put :setphoto
      get :followers
      get :intro
      get :marked
      post :sent_apply
    end
    collection do
      put :unconfirm 
      get :archives 
      get :total_topics
    end
  end

  resources :activities do
    member do
      post :join
      get :mainphoto
      post :mainphoto_create 
      delete :quit  
    end
    collection do
      get :with_school 
      get :category 
      get :ongoing 
      get :over 
      get :total_topics
    end
  end
  
  resources :groups do 
    member do
      get :join
      get :quit
      get :new_topic
      get :managers
      get :invite
      get :send_invitation
      get :members
    end
    collection do 
      get :all
      get :participated
      get :submitted
    end
  end
  
  resources :boxes do
    collection do 
      get :apply
      get :feedback
      get :topics 
      get :photos 
      post :submit 
      get :new_photo
      get :new_topic
      get :execution
      get :executions
    end
  end
  
  resources :teams do
    member do
      get :managers
      get :search_user
      post :add
      delete :leave
      get :new_activity
      post :create_activity
      post :follow
      delete :unfollow
      get :large_map
      get :managers
    end
  end

  
  #namespace :admin do 
    #get '/' => "misc#index"
    #resources :boxes
    #resources :bringings do
      #put :validate,:on => :member 
      #put :refuse,:on =>   :member 
    #end
    #resources :permissions
    #resources :users do
     #get :serach, :on => :collection 
     #put :block,  :on => :member
    #end
    #resources :geos
    #resources :counties
    #resources :schools
    #resources :pages
    #resources :groups
    #resources :game_categories
    #resources :co_donations do
      #member do
        #put :validate
        #put :cancel
      #end
    #end
    #resources :teams do
      #member do
        #put :validate
        #put :cancel
      #end
    #end
    #resources :bulletins
    #resources :projects do
      #member do
        #put :validate
        #get :refuse_letter 
        #put :cancel
      #end
    #end
  #end

end
