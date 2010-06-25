namespace :misc do

  desc "备份数据库"
  task :backup do
    '/usr/ruby /home/jill/mysql_backup/mysql_tools.rb backup'
  end
  
  desc "判定一周内没有上传证明的捐赠无效"
  task :check_sub_donation do
    SubDonation.all.map{|s| s.refuse if s.state == "ordered" && s.created_at < 8.days.ago}
  end
  
  desc "为有分享的结束活动标记"
  task :activity_done => :environment do
    Activity.find(:all,:conditions => {:done => false}).each do |a|
      if a.end_at < 1.day.ago
        done = true
        a.update_attribute(:done,done)
        $stdout.putc('.')
      end
    end
  end


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

end