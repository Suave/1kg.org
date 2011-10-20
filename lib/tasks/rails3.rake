namespace :rails3 do
  desc "转移照片到paperclip"
  task :photos_paperclip => :environment do
    Photo.find(:all,:conditions => {:parent_id => nil}).each do |p|
     origin_dir = "public/photos/#{p.id.to_s.rjust(8, '0')[0..3]}/#{p.id.to_s.rjust(8,'0')[4..-1]}/"
     goal_dir = "public/media/photos/#{p.id}"
     ext = p.filename[-3..-1]
     `cp -r #{origin_dir} #{goal_dir}/`
     `mv #{goal_dir}/#{p.filename} #{goal_dir}/original.jpg`
     `mv #{goal_dir}/#{p.filename[0..-5]}_small.#{ext} #{goal_dir}/240x180.jpg`
     `mv #{goal_dir}/#{p.filename[0..-5]}_thumb.#{ext} #{goal_dir}/107x80.jpg`
     `rm #{goal_dir}/#{p.filename[0..-5]}_square.#{ext}`
     `rm #{goal_dir}/#{p.filename[0..-5]}_medium.#{ext}`
    end
  end
end
