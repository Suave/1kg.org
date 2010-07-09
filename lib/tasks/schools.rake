require 'fastercsv'
require 'hpricot'
require 'open-uri'
require 'cgi'
require 'gmap'

include GMap

namespace :schools do
  desc "删除失效的大使权限"
  task :role_delete => :environment do
    roles = Role.all.map{|r| r if r.identifier =~ /^roles.school.moderator./}.compact
    roles.each do |r|
      if School.find(:first,:conditions => {:id => (r.identifier).split('.').last.to_i}) == nil
        r.delete 
        $stdout.putc('.')
        $stdout.flush
      end
    end
  end  
  
  desc "删除失效的用户动态"
  task :visited_delete => :environment do
    Visited.all.each do |r|
      if School.find(:first,:conditions => {:id => r.school_id}) == nil
        r.delete 
        $stdout.putc('.')
        $stdout.flush
      end
    end
  end  

  
  desc "count schools' karma(popularity)"
  task :popularity => :environment do
    schools = School.validated
    puts "学校总数：#{schools.size}"
    
    schools.each do |school|
      karma = 0
      # 活动 20s/个 （另外活动回复 1/s + 参加 2/s）
      school.activities.each do |activity|
        karma += activity.comments.count * 1
        karma += activity.participators.count * 2
        karma += 20
      end
      # 照片 2s/张
      karma += school.photos.count * 2
      # 分享 10s/篇 (另外 分享回复 1s/个)
      school.shares.each do |share|
        karma += share.comments.count * 1
        karma += 10
      end
      # 话题回复 1s/个 学校话题 2s/个
      school.discussion.board.topics.each do |topic|
        karma += topic.posts.count * 1
        karma += 2
      end
      # 去过用户 4s/人  要去 2s/人  关注  2s/人
      karma += school.visitors.count * 4
      karma += school.interestings.count * 2
      karma += school.wannas.count * 2
      # 学校大使 10s/人
      karma += User.moderators_of(school).size * 10
      
      # 更新学校活跃度
      school.update_attribute(:karma, karma) #unless school.karma == karma

      # 更新学校当月平均活跃度
      #last_month_karma = karma - school.snapshots.find_by_created_on(Date.today - 1.month).karma rescue karma
      #puts last_month_karma
      #school.update_attribute(:last_month_karma, last_month_karma)
      #puts "#{school.title}: #{last_month_karma}" unless karma == 0
    end
  end 
  
  desc "初始化Counter cache"
  task :counter_cache => :environment do
    User.all.each do |user|
      puts user.login
      user.posts_count = user.posts.count
      user.shares_count = user.shares.count
      user.guides_count = user.guides.count
      user.topics_count = user.topics.count
      user.save(false)
    end
  end
  
  desc "import all schools to db/schools.csv"
  task :export => :environment do
    file = File.open("#{RAILS_ROOT}/db/schools.csv", 'w')
    
    csv_string = FasterCSV.generate do |csv|
      # generate header
      csv << ['id', 'name', 'address', 'introduction', 'times', 'shares', 'last_update']
      
      # generate content
      School.avaiable.each do |school|
        last_share = school.shares.last
        last_update = last_share.nil? ? '无' : "#{last_share.updated_at.to_date} by #{last_share.user.login}"
        introduction = "年级：#{school.level_amount}，班级：#{school.class_amount}，老师：#{school.teacher_amount}，学生：#{school.student_amount}"
        csv << [school.id, school.title, school.basic.address, introduction, school.visitors.count, school.shares.count, last_update]
        $stdout.putc('.')
        $stdout.flush
      end
    end
    
    file.write(csv_string)
    file.close
    puts ''
    puts "#{School.count} schools updated."
  end

  desc "generate a json file used for google map"
  task :to_json => :environment do
    require 'json'
    schools = School.validated
    schools_json = []
    schools.each do |school|
      if school.basic.blank?
        puts "#{school.id} -- #{school.title}"
        next
      end
      schools_json << {:i => school.id,
                       :t => school.icon_type,
                       :n => school.title,
                       :a => school.basic.latitude,
                       :o => school.basic.longitude
                      }
    end
    
    file = File.open("#{RAILS_ROOT}/public/schools.json", 'w')
    file.write('var schools =')
    file.write schools_json.to_json
    file.close
  end
    
  namespace :coordinates do
    desc "generate coordinates for all schools"
    task :generate => :environment do
      School.all.each do |school|
        coordinates = find_coordinates_by_address(school.basic.address)
        school.basic.longitude = coordinates[0]
        school.basic.latitude  = coordinates[1]
        school.basic.save(false)
        puts school.title + ':' + school.basic.longitude + ',' + school.basic.latitude
      end
    end
  end
end

namespace :geo do
  namespace :coordinates do
    desc "generate coordinates for all geos"
    task :generate => :environment do
      Geo.all.each do |geo|
        coordinates = find_coordinates_by_address(geo.name)
        geo.longitude = coordinates[0]
        geo.latitude = coordinates[1]
        geo.save(false)
        puts geo.name + ':' + geo.longitude + ',' + geo.latitude
      end
    end
  end
end

namespace :following do
  desc "generate coordinates for all geos"
  task :generate => :environment do
    Neighborhood.all.each do |n|
      Following.create(:follower_id => n.user_id, :followable_id => n.neighbor_id, :followable_type => 'User') unless Following.find(:first, :conditions => ['follower_id = ? and followable_id = ? and followable_type = ?', n.user_id, n.neighbor_id, 'User'])
    end
    
    Visited.all.each do |v|
      next unless v.status == 2
      Following.create(:follower_id => v.user_id, :followable_id => v.school_id, :followable_type => 'School') unless Following.find(:first, :conditions => ['follower_id = ? and followable_id = ? and followable_type = ?', v.user_id, v.school_id, 'School'])
    end
  end
end

