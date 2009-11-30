class MallController < ApplicationController
  def index
    @recommends = Good.recommends
    @latest = Good.latest
  end
  
  def category
    @goods = Good.find_tagged_with(params[:tag])
  end
  
  def show
    @good = Good.find params[:id]
    @photos = @good.photos
  end
  
  
end