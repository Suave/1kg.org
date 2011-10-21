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

  desc "活动简介字段更新"
  task :activities_sanitize => :environment do 
    Activity.all.each do |a|
      a.save
      printf '.'
    end
  end

  desc "删除无用的Model"
  task :delete_unusage_photos => :environment do 
    Photo.find(:all,:conditions => 'parent_id is not null').each do |p|
      p.delete
    end
  end

  desc "用多态关联照片"
  task :polymorphic_photos => :environment do 
    Photo.find(:all,:conditions => {:parent_id => nil}).each_with_index do |p,index|
      photoable = {'Execution' => p.execution_id,'School' => p.school_id,'CoDonation' => p.co_donation_id,'Activity' => p.activity_id,'Requirement' => p.requirement_id}.map{|key,value| key.constantize.find_by_id(value) if value}.compact.first
      if photoable
        p.update_attributes(:photoable_id => photoable.id,:photoable_type => photoable.class.name)
        p.save
      end
    end
  end
end

