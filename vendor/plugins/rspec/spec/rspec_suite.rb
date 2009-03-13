if __FILE__ == $0
  dir = File.dirname(__FILE__)
  Dir["#{dir}/**/*_spec.rb"].reverse.each do |file|
<<<<<<< HEAD:vendor/plugins/rspec/spec/rspec_suite.rb
=======
#    puts "require '#{file}'"
>>>>>>> c0ecd1809fb41614ff2905f5c6250ede5f190a92:vendor/plugins/rspec/spec/rspec_suite.rb
    require file
  end
end
