ActionController::Routing::Routes.draw do |map|
  root :to  => "misc#index"
  match 'signup' => 'users#new', :as => :signup
  match 'register' => 'users#create', :as => :register
  match 'setting' => 'users#edit', :as => :setting
  match 'login' => 'sessions#new', :as => :login
  match 'logout' => 'sessions#destroy', :as => :logout
  match 'reset_password' => 'sessions#reset_password',:as => :reset_password 
  match 'forget_password' => 'sessions#forget_password',:as => :forget_password 
  match "/sent/by_system" => "sent#by_system"

  get "/public" =>  "misc#public_look"
  get "/misc/:slug" => "misc#show_page"
  get  "/tags/needs" => "tags#needs"
  get  "/tags/:tag" => "tags#show"

  resources :executions
  resources :messages
  resources :managements
  resources :votes
  resources :themes
  resources :photos
  resources :tags
  resources :topics
  resources :comments
  resources :bulletins
  resource :session
  
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

  resources :projects, :member => {:manage => :get,:large_map => :get,:topics => :get ,:photos => :get} do |project|
      resources :executions, :member => {:info_window => :get,:validate => :put,:refuse => :put,:finish => :put,:refuse_letter => :get,:feedback => :get} do |execution|
    end
  end
  
  namespace :admin do 
    get '/' => "misc#index"
    resources :boxes
    resources :bringings do
      put :validate,:on => :member 
      put :refuse,:on =>   :member 
    end
    resources :permissions
    resources :users do
     get :serach, :on => :collection 
     put :block,  :on => :member
    end
    resources :geos
    resources :counties
    resources :schools
    resources :pages
    resources :groups
    resources :game_categories
    resources :co_donations do
      member do
        put :validate
        put :cancel
      end
    end
    resources :teams do
      member do
        put :validate
        put :cancel
      end
    end
    resources :bulletins
    resources :projects do
      member do
        put :validate
        get :refuse_letter 
        put :cancel
      end
    end
  end

  # 专题页面
  namespace :minisite do 
    get "weixingfu" => "weixingfu#index"
    get "mangexingdong" => "mangexingdong#index"
    get "mangexingdong/poster" => "mangexingdong#poster"
    namespace :postcard do 
      # index    '',         :action => "index"
      # password 'password', :action => "password"
      # give     'give/:id', :action => "give"
      # comment  'comment/:id', :action => "comment"
      # messages 'messages', :action => "messages"
      # donors   'donors/:id', :action => "donors"
      # love_message 'love_message', :action => "love_message"
    end
    
    namespace :mooncake do |mooncake|
      # index    '',         :action => "index"
      # password '/password',:action => "password"
      # comment  '/comment', :action => "comment"
      # love_message 'love_message', :action => "love_message"
      # messages 'messages', :action => "messages"
      # donors   'donors/:id', :action => "donors"
    end
    
    namespace :lightenschool do |lightenschool|
      # index    '',         :action => "index"
        #dash.submit   'submit',   :action => "submit"
      # required   'required', :action => "required"
        #dash.processing 'processing',  :action => "processing"
      # processing 'winners',  :action => "winners"
    end
    
    namespace :kuailebox do |kuailebox|
      # index    '',         :action => "index"
    end
    
    namespace :cnbloggercon09 do |cnbloggercon09|
      # index    '',         :action => "index"
    end
    
    namespace :festcard09 do |festcard09|
      # index    '',         :action => "index"
      # cards   '/cards',    :action => "cards"
      # password '/password',:action => "password"
      # comment  '/comment', :action => "comment"
    end
    
    namespace :musicclassroom do |musicclassroom|
      # index    '',         :action => "index"
    end
  end
end
