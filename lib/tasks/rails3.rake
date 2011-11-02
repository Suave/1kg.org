namespace :rails3 do
  desc "转移照片到paperclip"
  task :photos_paperclip => :environment do
    Photo.find(:all,:conditions => {:parent_id => nil},:order => 'created_at desc').each do |p|
     origin_dir = "public/photos/#{p.id.to_s.rjust(8, '0')[0..3]}/#{p.id.to_s.rjust(8,'0')[4..-1]}/"
     goal_dir = "public/media/photos/#{p.id}/images"
     ext = p.filename[-3..-1]
     `mkdir public/media/photos/#{p.id}`
     `cp -r #{origin_dir} #{goal_dir}`
     `mv #{goal_dir}/#{p.filename} #{goal_dir}/original.#{ext.downcase}`
     `mv #{goal_dir}/#{p.filename[0..-5]}_thumb.#{ext} #{goal_dir}/107x80.#{ext.downcase}`
     `mv #{goal_dir}/#{p.filename[0..-5]}_small.#{ext} #{goal_dir}/max240x180.#{ext.downcase}`
     `mv #{goal_dir}/#{p.filename[0..-5]}_medium.#{ext} #{goal_dir}/max565x420.#{ext.downcase}`
     `rm #{goal_dir}/#{p.filename[0..-5]}_square.#{ext}`
      p.update_attribute(:image_file_name,"#{p.filename[0..-5]}.#{ext.downcase}")
    end
  end

  desc "转移头像到paperclip"
  task :avatars_paperclip => :environment do
    User.all.each do |u|
      origin_dir = "public/users/#{p.id.to_s.rjust(8, '0')[0..3]}/#{p.id.to_s.rjust(8,'0')[4..-1]}/"
    end
  end

  desc "修改所有的分享照片链接"
  task :shares_photo_link => :environment do 
    Share.find(:all).each do |s|
      while s.clean_html.match(/\/photos\/(\d{4})\/(\d{4})\/.+?(jpg|JPG|png|PNG|gif|GIF)\"/) do
        s.clean_html = s.clean_html.sub(/\/photos\/(\d{4})\/(\d{4})\/.+?(jpg|JPG|png|PNG|gif|GIF)\"/,"\/media\/photos\/#{($1+$2).to_i}\/images/max565x420.#{$3.downcase}\"")
        printf '.'
      end
      s.save(false)
      puts s.id
    end
  end

  desc "修改所有的话题照片链接"
  task :topics_photo_link => :environment do 
    Topic.find(:all).each do |s|
      while s.clean_html.match(/\/photos\/(\d{4})\/(\d{4})\/.+?(jpg|JPG|png|PNG|gif|GIF)\"/) do
        s.clean_html = s.clean_html.sub(/\/photos\/(\d{4})\/(\d{4})\/.+?(jpg|JPG|png|PNG|gif|GIF)\"/,"\/media\/photos\/#{($1+$2).to_i}\/images/max565x420.#{$3.downcase}\"")
        printf '.'
      end
      s.save(false)
      puts s.id
    end
  end
 
  desc "修改所有活动照片链接"
  task :activities_photo_link => :environment do 
    Activity.find(:all).each do |s|
      while s.clean_html.match(/\/photos\/(\d{4})\/(\d{4})\/.+?(jpg|JPG|png|PNG|gif|GIF)\"/) do
        s.clean_html = s.clean_html.sub(/\/photos\/(\d{4})\/(\d{4})\/.+?(jpg|JPG|png|PNG|gif|GIF)\"/,"\/media\/photos\/#{($1+$2).to_i}\/images/max565x420.#{$3.downcase}\"")
        printf '.'
      end
      s.save(false)
      puts s.id
    end
  end

  desc "话题直接多态关联"
  task :topics_polymorphic => :environment do
    Topic.all.map do |t|
      puts t.id
      t.boardable = t.get_boardable
      t.save
    end
  end

  desc "用多态关联分享"
  task :polymorphic_shares => :environment do 
    Share.find(:all).each_with_index do |p,index|
      boardable = {'Execution' => p.execution_id,'School' => p.school_id,'Activity' => p.activity_id,'Requirement' => p.requirement_id}.map{|key,value| key.constantize.find_by_id(value) if value}.compact.first
      if boardable
        p.update_attributes(:boardable_id => boardable.id,:boardable_type => boardable.class.name)
        printf '.' if p.save(false)
      else
        printf 'x'
      end
    end
  end

  desc "原分享的推荐转移"
  task :votes_trans => :environment do 
    Vote.find(:all,:conditions =>{:voteable_type => 'Share'}).each do |v|
      v.update_attributes(:voteable_id => Topic.find_by_share_id(v.voteable_id).id,:voteable_type => 'Topic')
      print '.' if v.save
    end
  end
  
  desc "原分享的评论转移"
  task :comments_trans => :environment do 
    Comment.find(:all,:conditions =>{:commentable_type => 'Share'}).each do |c|
      c.update_attributes(:commentable_id => Topic.find_by_share_id(c.commentable_id),:commentable_type => 'Topic')
      print '.' if c.save
    end
  end
  
  desc "回复转换成评论"
  task :posts_to_comments => :environment do 
    Post.find(:all).each_with_index do |p,index|
      t = Comment.new(:post_id => p.id,
                    :body_html => p.body_html,
                    :user_id => p.user_id,
                    :commentable_id => p.topic_id,
                    :commentable_type => 'Topic',
                    :comments_count => p.comments_count
                    )
      if t.save
        t.created_at = p.created_at
        t.save
        printf '.'
      else
        printf 'x'
      end
    end
  end
  
  desc "分享转移成话题"
  task :shares_to_topics => :environment do 
    Share.find(:all).each do |s|
      t = Topic.new(:share_id => s.id,
                    :clean_html => s.clean_html,
                    :title => s.title,
                    :user_id => s.user_id,
                    :board_id => 0,
                    :boardable_id => s.boardable_id,
                    :boardable_type => s.boardable_type,
                    :comments_count => s.comments_count,
                    :last_modified_at => s.last_modified_at,
                    :last_modified_by_id => s.last_modified_by_id,
                    :last_replied_at => s.last_replied_at,
                    :last_replied_by_id => s.last_replied_by_id
                    )
      if t.save
        t.created_at = s.created_at
        t.save
        printf '.'
      else
        printf 'x'
      end
    end
  end

  desc "转移权限到management"
  task :rebuild_role => :environment do 
    Leadership.all.each do |l|
      puts 'f' if Management.new(:user_id => l.user_id,:manageable_type => 'Team',:manageable_id => l.team_id).save
      
    end

    RolesUser.all.each do |r|
      if r.role
        if r.role.id == 1
          printf 'a' if User.find(r.user_id).update_attribute(:is_admin,true)
        elsif r.role.id == 2

        else
          manageable_id = r.role.identifier.match(/(\d.*)$/)[1].to_i
          case r.role.identifier.match(/^roles.(.*).moderator/)[1]
          when 'school'
            printf 's' if Management.new(:user_id => r.user_id,:manageable_type => 'School',:manageable_id => manageable_id).save
          when 'board'
             board = Board.find_by_id(manageable_id)
             if board && board.talkable_type == "GroupBoard" && board.talkable.group
                Management.new(:user_id => r.user_id,:manageable_type => 'Group',:manageable_id => board.talkable.group.save).save
                printf 'g'
             end
          end
        end
      end
    end
  end
end

