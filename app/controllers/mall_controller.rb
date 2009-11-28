class MallController < ApplicationController
  def index
    
  end
  
  def category
    @goods = Good.find_tagged_with(params[:tag])
  end
  
  def show
    @good = Good.find params[:id]
    @photos = @good.photos
  end
  
  
end