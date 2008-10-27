require "rubygems"
require "active_record"
require "yaml"

$config = YAML.load_file(File.join(File.dirname(__FILE__), 'database.yml'))

class LegacyDatabase < ActiveRecord::Base
  establish_connection $config["legacy"]
end

class SurvivalDatabase < ActiveRecord::Base
  establish_connection $config["survival"]
end

module Legacy
  class Area < LegacyDatabase
    set_table_name 'areas'
  end
end

module Survival
  class Geo < SurvivalDatabase
    set_table_name 'geos'
  end
end

provinces = Legacy::Area.find(:all, :conditions => "parent_id is null or parent_id=0")
#puts area_roots.size
#puts area_roots.collect{|a| a.title}
provinces.each do |province|
  new_province = Survival::Geo.new(:name => province.title, :zipcode => province.zipcode)
  new_province.save!
  
  cities = Legacy::Area.find(:all, :conditions => ["parent_id = ?", province.id])
  cities.each do |city|
    new_city = Survival::Geo.new(:name => city.title, :zipcode => city.zipcode)
    new_city.move_to_child_of new_province
  end
end

puts Survival::Geo.count(:all)
  
  