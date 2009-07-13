namespace :group do 
  desc "convert city dicussion to group"
  task :convert => :environment do
    default_moderator = User.find_by_email("1kg.org@gmail.com") # default moderator is 多背一公斤
    
    Geo.find(:all).each do |geo|
      # 老的城市管理员实际上用的是城市讨论区版主的角色，现在移去城市讨论区，需要创建一个新的城市管理员角色
      city_moderator_role = Role.create!( :identifier => "roles.geo.moderator.#{geo.id}", 
                                          :description => "#{geo.name}城市管理员" )
      
      # check if city board existed
      next if geo.city_board.nil?
      
      # check if any topic exist in this city board
      topics = geo.city_board.board.topics 
      next if topics.blank?
      
      puts "#{geo.name}: #{topics.size} topics"
      
      # create group
      # default creator: /users/1 多背一公斤
      group = Group.create!(:title => geo.name, :geo_id => geo.id, :user_id => default_moderator.id)
      
      # move topics
      Topic.update_all "board_id=#{group.discussion.board.id}", "board_id=#{geo.city_board.board.id}"
      
      # convert city moderators to group moderators
      city_moderators =  User.moderators_of(geo.city_board.board)
      group_moderator_role = Role.find_by_identifier("roles.board.moderator.#{group.discussion.board.id}")
      if city_moderators.blank?
        default_moderator.roles << group_moderator_role unless default_moderator.roles.include?(group_moderator_role)
        puts "将 #{default_moderator.login} 设为 #{group.title}小组管理员"
      else
        city_moderators.each do |m|
          m.roles << group_moderator_role unless m.roles.include?(group_moderator_role) # 给老城管添加组长角色
          m.roles << city_moderator_role unless m.roles.include?(group_moderator_role) # 给老城管添加新的城市管理员角色
          puts "将 #{m.login} 设为 #{group.title}小组管理员，和#{geo.name}城管"
        end
      end
      
      # 将城市居民添加为组员
      geo.users.each do |citizen|
        group.members << citizen
      end
      
      puts "-------------------------------------"
      puts "完成#{geo.name}的转换"
      puts "-------------------------------------"
      
    end
  end
end