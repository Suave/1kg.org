namespace :misc do
  desc "为有分享的结束活动标记"
  task :activity_done => :environment do
    Activity.find(:all,:conditions => {:done => false}).each do |a|
      if a.end_at < (Time.now - 1.day)
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

