class Minisite::WeixingfuController < ApplicationController
  def index
    @group = Group.find(:first,:conditions=>{:slug => 'weixingfu'})
  
  end
end
