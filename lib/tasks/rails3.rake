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
  end

  desc "更新话题的html"
  task :topics_sanitize => :environment do 
  def sanitize(text, replace = false)
    html = text
    if replace
      html = text.dup
      html.gsub!( '</p>', "\n")
      html.gsub!( '<br/>', "\n")
      html.gsub!(/<.*?>/, '')

      url_regex = /(?#Protocol)(?:(?:ht|f)tp(?:s?)\:\/\/|~\/|\/)?(?#Username:Password)(?:\w+:\w+@)?(?#Subdomains)(?:(?:[-\w]+\.)+(?#TopLevel Domains)(?:com|org|net|gov|mil|biz|info|mobi|name|aero|jobs|museum|travel|[a-z]{2}))(?#Port)(?::[\d]{1,5})?(?#Directories)(?:(?:(?:\/(?:[-\w~!$+|.,=]|%[a-f\d]{2})+)+|\/)+|\?|#)?(?#Query)(?:(?:\?(?:[-\w~!$+|.,*:]|%[a-f\d{2}])+=?(?:[-\w~!$+|.,*:=]|%[a-f\d]{2})*)(?:&(?:[-\w~!$+|.,*:]|%[a-f\d{2}])+=?(?:[-\w~!$+|.,*:=]|%[a-f\d]{2})*)*)*(?#Anchor)(?:#(?:[-\w~!$+|.,*:=]|%[a-f\d]{2})*)?/i

      html.gsub!(url_regex) { |url|
        "<a href=\"#{url}\">#{url}</a>"
      }

      html.gsub!("\r\n", '<br/>')
      html.gsub!("\r", '<br/>')
      html.gsub!("\n", '<br/>')
    end
    
    begin
      html = Sanitize.clean(html, :elements => ['a', 'div', 'span', 'img', 'p', 'embed', 'br',
        'em','strong', 'strike', 'ol', 'ul', 'li', 'table', 'tbody', 'td', 'tfoot', 'th', 'thead', 'tr', 'tt', 'param', 'object'],
          :attributes => {'a' => ['href', 'target', 'title'], 
            'img' => ['src', 'alt', 'title'], 
            'span' => ['style'],
            'object' => ['width', 'height'],
            'td' => ['colspan', "rowspan",'width', 'height'],
            'tr' => ['width', 'height'],
            'table' => ['border'],
            'param' => ['name', 'value'],
            'object' => ['data','type', 'width', 'height'],
            'embed' => ['src', 'type', 'allowscriptaccess', 'allowfullscreen', 'wmode', 'width', 'height']})
    rescue
      html
    end
  end

    Topic.find(:all,:conditions => {:clean_html=>nil}).each do |t|
      t.clean_html = sanitize(t.body_html)
      puts t.id if t.save
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

