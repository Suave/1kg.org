class PhotosController < ApplicationController
  before_filter :login_required
  
  def show
    @photo = Photo.find(params[:id])
  end
  
end