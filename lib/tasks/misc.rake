namespace :misc do

  desc "备份数据库"
  task :backup do
    '/usr/ruby /home/jill/mysql_backup/mysql_tools.rb backup'
  end
 
  desc "为没有坐标的团队设定初始位置"
  task :set_team_position  => :environment do
    Team.find(:all,:conditions => {:latitude => nil}).each do |t|
      t.latitude,t.longitude = t.geo.latitude,t.geo.longitude
      t.save
    end
  end

  desc "项目报告转移道分享"
  task :trans_report => :environment do
    Execution.all.map{|e| e unless  e.feedback.blank?}.compact.each do |e|
      @share = Share.new(:body_html => e.feedback,:updated_at => e.last_modified_at,:created_at => e.created_at,:school_id => e.school_id,:execution_id => e.id,:geo_id => 0)
      @share.title = "#{e.village_id.nil? ? e.school.title : e.village.title }的#{e.project.title}项目执行报告"
      @share.user = e.user
      puts @share.save
      puts @share.errors
    end
  end  


  
  desc "判定一周内没有上传证明的捐赠无效"
  task :check_sub_donation => :environment do
    SubDonation.state_is('ordered').each do |s|
      if (s.created_at < 7.days.ago)
        s.refuse
        message = Message.new(
          :subject => "你为#{s.co_donation.school.title}捐赠的#{s.quantity}件#{s.co_donation.goods_name}失效了",
          :content => "<p>亲爱的用户：<br/>由于你没有在一周内按时上传捐赠证明，你的捐赠失效了。<br/>团捐页面地址 => http://www.1kg.org/co_donations/#{s.co_donation.id} </p><br/><p>多背一公斤团队</p>"
          )
        message.author_id = 0
        message.to = [s.user]
        message.save!
      end
    end
  end
  
  desc "学校分享话题合并"
  task :topic_to_share => :environment do
    Topic.find(:all, :conditions => ["boards.talkable_type=?", "SchoolBoard"],:include => [:board]).each do |t|
      s = Share.new(
                  :user_id  => t.user_id,
                  :title => t.title,
                  :body_html => t.body_html,
                  :clean_html => t.clean_html,
                  :school_id => t.board.talkable.school_id,
                  :geo_id => t.board.talkable.school.geo_id,
                  :last_modified_at => t.last_modified_at,
                  :last_modified_by_id => t.last_modified_by_id,
                  :last_replied_at => t.last_replied_at,
                  :deleted_at => t.deleted_at,
                  :last_replied_by_id => t.last_replied_by_id,
                  :created_at => t.created_at,
                  :updated_at => t.updated_at
                  )
      puts "t_#{t.id}" if !s.save
      
      t.votes.each do |v|
        v.voteable_type = 'Share'
        v.voteable_id = s.id
        puts "v_#{v.id}" if !v.save
      end
        
      t.posts.each do |p|
        c = Comment.new(
                  :user_id  => p.user_id,
                  :body => p.body_html,
                  :commentable_type => "Share",
                  :commentable_id => s.id,
                  :deleted_at => p.deleted_at,
                  :created_at => p.created_at,
                  :updated_at => p.updated_at
                  )
        puts "p_#{p.id}" if !c.save
        p.comments.each do |reply|
          reply.update_attributes(:commentable_type => "Comment",:commentable_id => c.id)
        end
      end
      s.updated_at = t.updated_at
      s.save
    end
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