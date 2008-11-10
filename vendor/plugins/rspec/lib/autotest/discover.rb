Autotest.add_discovery do
<<<<<<< HEAD:vendor/plugins/rspec/lib/autotest/discover.rb
<<<<<<< HEAD:vendor/plugins/rspec/lib/autotest/discover.rb
  "rspec" if File.directory?('spec') && ENV['RSPEC']
=======
  "rspec" if File.exist?('spec') && ENV['RSPEC']
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/lib/autotest/discover.rb
=======
  "rspec" if File.exist?('spec') && ENV['RSPEC']
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/lib/autotest/discover.rb
end
