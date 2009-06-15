namespace :password do 
  desc "generate some password"
  task :generate => :environment do 
    file = File.open("#{RAILS_ROOT}/db/passwords.csv")
    buck = StuffBuck.create(:type_id => 1, :school_id => 1, :quantity => 0, :hidden => true, :status => "dup")
    
    file.each do |line|
      #puts line.chomp!
#=begin
      3.times do 
        stuff = Stuff.create(:code => line.chomp, :type_id => 1, :buck_id => buck.id)
        puts "#{stuff.code} -- #{stuff.type_id} -- #{stuff.buck_id}"
      end
#=end
    end
  end
end