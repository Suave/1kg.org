class PhotosController < ApplicationController
  before_filter :login_required, :except => [:show, :gallery]
  session :cookie_only => false, :only => %w(create) 
  skip_before_filter :verify_authenticity_token
  
  def new
    @photo = Photo.new(:school_id => params[:school_id], :activity_id => params[:activity_id])
  end
  
  def create
    @photo = current_user.photos.build(params[:photo])
    # 针对Flash上传
    @photo.swf_uploaded_data = params[:Filedata] if params[:Filedata]
    @photo.title = '未命名图片' unless @photo.title.blank?
    @photo.save!
    flash[:notice] = "照片上传成功!"
    
    if params[:Filedata]
      render(:text => @photo.id)
    else
      redirect_to @photo.school || @photo.activity
    end
  end
  
  def gallery
    @photo = Photo.find(params[:id])
    render :partial => '/schools/gallery_photo', :object => @photo, :layout => false
  end
  
  def update
    @photo = current_user.photos.find(params[:id])
    @photo.update_attributes(params[:photo])
    
    render :text => 'Success'
  end
  
  def destroy
    @photo = current_user.photos.find(params[:id])
    @photo.destroy
    flash[:notice] = "照片已经删除"
    if !@photo.school_id.blank?
      redirect_to school_url(@photo.school_id)
    elsif !@photo.activity_id.blank?
      redirect_to activity_url(@photo.activity_id)
    else
      redirect_to user_url(@photo.user_id)
    end
  end
  
  
  def show
    @photo = Photo.find(params[:id])
    @photo.user_id = 1 if @photo.user.nil?
  end
end