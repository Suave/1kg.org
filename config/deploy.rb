#require 'capistrano/ext/multistage'
default_run_options[:pty] = true

set :application, "1kg"
set :user, "1kg"
set :repository, "git://github.com/Suave/1kg.org.git"
set :scm, :git

role :app, "1kg.org", :primary => true
role :web, "1kg.org"
role :db, "1kg.org", :primary => true

namespace :deploy do
  set :deploy_to, "/home/1kg/master"  
  # namespace :web do
  #   task :disable, :roles => [:app, :web] do
  #     on_rollback { delete "#{shared_path}/system/maintenance.html" }
  #     
  #     require 'rubygems' 
  #     require 'haml'
  #     
  #     template = File.read("./app/views/layouts/maintenance.html.haml")
  #     haml = Haml::Engine.new(template)
  #     maintenance = haml.render(Object.new,
  #                          :deadline => ENV['UNTIL'],
  #                          :reason => ENV['REASON'])
  # 
  #     put maintenance, "#{shared_path}/system/maintenance.html", 
  #                      :mode => 0644
  #   end
  # end
  
  desc "Custom after update code to put production database.yml in place."
  task :copy_configs, :roles => :app do
    run "cp #{deploy_to}/shared/database.yml #{deploy_to}/current/config/database.yml"
    run "ln -s #{deploy_to}/shared/photos #{deploy_to}/current/public/photos"
    run "rm -rf #{deploy_to}/current/public/user && ln -s #{deploy_to}/shared/user #{deploy_to}/current/public/user"
    run "ln -s #{deploy_to}/shared/group #{deploy_to}/current/public/group"    
    run "cd #{current_path} && rake schools:to_json"
  end
  
  desc "Deploy to dev server"
  task :dev do
    # put up the maintenance screen
    # ENV['REASON'] = 'an application upgrade'
    # ENV['UNTIL']  = Time.now.+(600).strftime("%H:%M %Z")
    # web.disable
    set :deploy_to, "/home/1kg/dev"
    set :branch, "dev"
    set :env, "production"
    
    transaction do
      update_code
      symlink
      copy_configs
      migrate
    end
    
    restart
    
    # remove the maintenance screen
    #web.enable
  end
  
  desc "Long deploy will update the code migrate the database and restart the servers"
  task :master do
    # put up the maintenance screen
    #     ENV['REASON'] = 'an application upgrade'
    #     ENV['UNTIL']  = Time.now.+(600).strftime("%H:%M %Z")
    #     web.disable
    set :deploy_to, "/home/1kg/master"
    set :branch, "master"
    set :env, "production"
    
    transaction do
      update_code
      symlink
      copy_configs
      migrate
    end
    
    restart

    # remove the maintenance screen
    #web.enable
  end
  
  desc "Rake database"
  task :migrate, :roles => :app, :only => {:primary => true} do
    run "cd #{deploy_to}/current && RAILS_ENV=#{env} rake db:schema:load"
  end
  
  desc "Restart the app server"
  task :restart, :roles => :app do
    run "cd #{deploy_to}/current && touch tmp/restart.txt"
  end
    
  desc "Tail the Rails log..."
  task :tail_logs, :roles => :app do
    run "tail -f #{deploy_to}/current/log/#{env}.log" do |channel, stream, data|
      puts  # for an extra line break before the host name
      puts "#{channel[:server]} -> #{data}" 
      break if stream == :err    
    end
  end
end
