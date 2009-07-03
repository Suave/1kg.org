require 'fastercsv'
require 'hpricot'
require 'open-uri'
require 'cgi'
require 'gmap'

include GMap

namespace :schools do
  desc "import all schools to db/schools.csv"
  task :export => :environment do
    file = File.open("#{RAILS_ROOT}/db/schools.csv", 'w')
    
    csv_string = FasterCSV.generate do |csv|
      # generate header
      csv << ['id', 'name', 'address', 'introduction', 'times', 'shares', 'last_update']
      
      # generate content
      School.all.each do |school|
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
  
  desc "import meta schools from db/schools.csv"
  task :import => :environment do
    file = File.open("#{RAILS_ROOT}/db/schools.csv", 'r')
    file.each_line do |line|
      attributes = line.split(',')
      
      address = attributes[1]
      city = ''
      if address.include?('省') || address.include?('自治区') || address.include?('特别行政区')
        city = address.gsub!(/省(.*?)$/, '')
        city = address.gsub!(/自治区(.*?)$/, '')
        city = address.gsub!(/特别行政区(.*?)$/, '')
      else
        city = address.gsub!(/市(.*?)$/, '')
      end
      geo = Geo.find_by_name(city) || Geo.first
      
      school = School.new(:title => attributes[4], :meta => true, :validated => false, :geo_id => geo)
      school.basic = SchoolBasic.new(:address => attributes[1], 
                                      :zipcode => attributes[6], 
                                      :master => attributes[3], 
                                      :telephone => attributes[2])
      
      if school.save
        puts school.id 
      else
        puts school.errors.full_messages
      end
    end
  end

  desc "generate a json file used for google map"
  task :to_json => :environment do
    require 'json'
    schools = School.all
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
  
  desc "check if school's discussion exist"
  task :discussion_check => :environment do
    schools = School.find(:all)
    schools.each do |s|
      puts "#{s.title}(#{s.id}) has not discussion" unless s.discussion
      puts "#{s.discussion.id} has not board" unless s.discussion.board
    end

  end
  
  desc "initial school validated_at column"
  task :initial_validated_at => :environment do
    puts "-- begin initial schools' validated_at column"
    schools = School.validated.find :all
    schools.each do |s|
      s.update_attributes!(:validated_at => s.created_at)
    end
    puts "-- finish fullfill the validated_at column for validated schools"
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
