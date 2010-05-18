class BlogsController < ApplicationController
  def index
    render :layout => 'blogs'
  end
  
  def show
    render :layout => 'blogs'
  end
end
