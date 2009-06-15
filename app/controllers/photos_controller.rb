class PhotosController < ApplicationController
  before_filter :login_required, :except => :show
  
  def new
    @photo = Photo.new
    
    @photo.school = School.find(params[:school]) unless params[:school].blank?
    @photo.activity = Activity.find(params[:activity]) unless params[:activity].blank?
  end
  
  def create
    @photo = Photo.new(params[:photo])
    @photo.user = current_user
    logger.info("PHOTO: #{@photo.inspect}")
    @photo.save!
    flash[:notice] = "照片上传成功!"
    
    if !@photo.school_id.blank?
      redirect_to school_url(@photo.school_id)
    elsif !@photo.activity_id.blank?
      redirect_to activity_url(@photo.activity_id)
    else
      redirect_to user_url(current_user)
    end
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
  end
  
end