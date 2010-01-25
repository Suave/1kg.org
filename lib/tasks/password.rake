namespace :password do 

#   desc "generate some password"
#   task :generate => :environment do 
#     file = File.open("#{RAILS_ROOT}/db/passwords.csv")
#     buck = StuffBuck.create(:type_id => 1, :school_id => 1, :quantity => 0, :hidden => true, :status => "dup")
#     
#     file.each do |line|
#       #puts line.chomp!
# #=begin
#       3.times do 
#         stuff = Stuff.create(:code => line.chomp, :type_id => 1, :buck_id => buck.id)
#         puts "#{stuff.code} -- #{stuff.type_id} -- #{stuff.buck_id}"
#       end
# #=end
#     end
#   end

  # desc "auto fill mooncake's password"
  # task :mooncake_autofill => :environment do
  #   @stuff_type = StuffType.find_by_slug("mooncake")
  #   @stuff_buck = @stuff_type.bucks.first
  #   @stuffs = Stuff.find :all, :conditions => { :type_id => @stuff_type.id,
  #                                               :matched_at => nil,
  #                                               :school_id => nil, }
  #                                               
  #   puts @stuffs.size
  #   @stuffs.each do |stuff|
  #     stuff.update_attributes!(:matched_at => Time.now, :school_id => @stuff_buck.school.id, :auto_fill => true)
  #   end
  # end
  # 
  desc "generate festcard09 password for YouCheng Foundation"
  task :festcard_for_youcheng => :environment do
    @stuff_type = StuffType.find_by_slug("festcard09")
    (889001..890000).each do |i|
      @stuff = @stuff_type.stuffs.build(:code => i)
      puts @stuff.code if @stuff.save!
    end
  end
  
  desc "generate festcard09 password for YaYa website"
  task :festcard_for_yaya => :environment do
    @stuff_type = StuffType.find_by_slug("festcard09")
    (1..1000).each do |i|
      @stuff = @stuff_type.stuffs.build(:code => "YY#{"%04d" % i}") 
      puts @stuff.code if @stuff.save!
    end
  end
  
  desc "generate festcard09 password for G2 Group"
  task :festcard_for_g2group => :environment do
    @stuff_type = StuffType.find_by_slug("festcard09")
    (1..2000).each do |i|
      @stuff = @stuff_type.stuffs.build(:code => "G2#{"%04d" % i}") 
      puts @stuff.code if @stuff.save!
    end
  end
  
  desc "close unsaled postcard's passwords"
  task :close_password => :environment do
    file = File.open("#{RAILS_ROOT}/db/password.csv")
    @stuff_type = StuffType.find_by_slug("postcard")
    not_found = []
    
    file.each do |item|
      @stuff = Stuff.find(:first, :conditions => {:code => item.chomp, :matched_at => nil, :type_id => @stuff_type.id})
      if @stuff.nil?
        # not found
        not_found << item
      else
        # found, delete this password from DB
        @stuff.destroy
        puts "delete: #{@stuff.code} - #{@stuff.id}"
      end
    end
    
    puts "NOT FOUND following passwords:"
    
    not_found.each do |pass|
      puts pass
    end
  end
end