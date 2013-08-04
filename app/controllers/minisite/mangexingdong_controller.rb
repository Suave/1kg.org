# -*- encoding : utf-8 -*-
class Minisite::MangexingdongController < ApplicationController
  
  def index
    update_count('index_count')
    @group = Group.find(:first,:conditions=>{:slug => 'mangexingdong'})
  end
  
  def poster 
    update_count('poster_count')
  end

  private

  def update_count(count)
    File.open("#{RAILS_ROOT}/public/json/mangexingdong.json", 'r') do |file|
      @json = JSON.parse(file.readlines.to_s)
    end
    File.open("#{RAILS_ROOT}/public/json/mangexingdong.json", 'w') do |file|
      file.write((@json.merge({count => @json[count] + 1})).to_json)
    end
    @total_count = ((Time.now - Date.new(2011,9,10).to_time)/3600).to_i*{ 'index_count' => 15,'poster_count' => 5}[count] + 1 + @json[count]
  end
end
