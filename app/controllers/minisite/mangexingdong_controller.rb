class Minisite::MangexingdongController < ApplicationController
  before_filter :views_counter, :except => []
  
  def index
    @group = Group.find(:first,:conditions=>{:slug => 'mangexingdong'})
    @board = @group.discussion.board
  end
  
  def poster 
  end

  def views_counter
    File.open("#{RAILS_ROOT}/public/json/mangexingdong.json", 'r') do |file|
      @views_count = JSON.parse(file.readlines.to_s)['views_count'] + 1
    end
    File.open("#{RAILS_ROOT}/public/json/mangexingdong.json", 'w') do |file|
      file.write({'views_count' => @views_count}.to_json)
    end
    @total_count = ((Time.now - 1.month.ago)/3600).to_i*15 + @views_count
  end
end
