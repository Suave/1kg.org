class PhotosController < ApplicationController
  before_filter :login_required, :except => [:show]
  session :cookie_only => false, :only => %w(create) 
  skip_before_filter :verify_authenticity_token
  
  def new
    @photo = Photo.new
    
    @photo.school = School.find(params[:school]) unless params[:school].blank?
    @photo.activity = Activity.find(params[:activity]) unless params[:activity].blank?
  end
  
  def create
    @photo = Photo.new(params[:photo])
    @photo.swf_uploaded_data = params[:Filedata]
    @photo.school_id = params[:school_id]
    @photo.activity_id = params[:activity_id]
    @photo.user = current_user
    @photo.title = '未命名图片' unless @photo.title.blank?
    @photo.save!
    flash[:notice] = "照片上传成功!"
    
    render(:partial => '/schools/gallery_photo', :object => @photo)
  end
  
  def destroy
    @photo = Photo.find(params[:id])
    @photo.destroy
    flash[:notice] = "照片已经删除"
    if @photo.school.blank?
      redirect_to user_url(@photo.user_id)
    else
      redirect_to school_url(@photo.school_id)
    end
  end
  
  
  def show
    @photo = Photo.find(params[:id])
    @photo.user_id = 1 if @photo.user.nil?
  end
end