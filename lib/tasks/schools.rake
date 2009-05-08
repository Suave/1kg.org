require 'fastercsv'
require 'hpricot'
require 'open-uri'
require 'cgi'

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
  
  namespace :coordinates do
    desc "generate coordinates for all schools"
    task :generate => :environment do
      School.all.each do |school|
        address = school.basic.address
        
        if address.include?('乡') || address.include?('镇')
          address.gsub!(/[乡|镇](.*?)$/) {''}
        elsif address.include?('县')
          address.gsub!(/县(.*?)$/) {''} 
        else
          address.gsub!(/市(.*?)$/) {''}
        end
        puts address
        coordinates = find_coordinates_by_address(address)
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
    desc "generate coordinates for all schools"
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

def find_coordinates_by_address(address)
  url  = "http://maps.google.com/maps/geo?q=#{CGI.escape(address)}&output=xml"
  data = open(url)
  doc  = Hpricot(data)
  code = doc / 'code'

  if code.inner_text == '200'
    coordinates = doc / 'coordinates'
    coordinates.inner_text.split(',')
  else
    ['0', '0']
  end
end
