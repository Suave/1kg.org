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

  desc "auto fill mooncake's password"
  task :mooncake_autofill => :environment do
    @stuff_type = StuffType.find_by_slug("mooncake")
    @stuff_buck = @stuff_type.bucks.first
    @stuffs = Stuff.find :all, :conditions => { :type_id => @stuff_type.id,
                                                :matched_at => nil,
                                                :school_id => nil, }
                                                
    puts @stuffs.size
    @stuffs.each do |stuff|
      stuff.update_attributes!(:matched_at => Time.now, :school_id => @stuff_buck.school.id, :auto_fill => true)
    end
  end
  
  desc "generate festcard09 password for YouCheng Foundation"
  task :festcard_for_youcheng => :environment do
    @stuff_type = StuffType.find_by_slug("festcard09")
    (889001..890000).each do |i|
      @stuff = @stuff_type.stuffs.build(:code => i)
      puts @stuff.code if @stuff.save!
    end
  end
end