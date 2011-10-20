class PhotosController < ApplicationController
  before_filter :login_required, :except => [:show, :gallery, :index]
  session :cookie_only => false, :only => %w(create) 
  skip_before_filter :verify_authenticity_token
  
  def index
    @photos = current_user.photos.paginate(:page => params[:page], :per_page => 5, :order => 'created_at DESC')
    
    respond_to do |wants|
      wants.html {render :layout => false}
    end
  end
  
  def new
    @photo = Photo.new(:execution_id => params[:execution_id],:school_id => params[:school_id], :activity_id => params[:activity_id])
  end
  
  def create
    @photo = current_user.photos.build(params[:photo])
    @photo.title = '未命名图片' if @photo.title.blank?
    if @photo.save
      flash[:notice] = "照片上传成功!" 
    end
    respond_to do |wants|
      if @photo.school || @photo.activity || @photo.execution
        wants.html {redirect_to @photo.school || @photo.activity || @photo.execution}
      else
        wants.html {render 'insert', :layout => false}
      end
    end
  end
  
  def gallery
    @photo = Photo.find(params[:id])
    render :partial => '/schools/gallery_photo', :object => @photo, :layout => false
  end
  
  def mce
    @photo = Photo.find(params[:id])
    render :layout => false
  end
  
  def update
    @photo = current_user.photos.find(params[:id])
    @photo.update_attributes(params[:photo])
    render :text => 'Success'
  end
  
  def destroy
    @photo = Photo.find(params[:id])
    if @photo.editable_by?(current_user)
      @photo.destroy
      flash[:notice] = "照片已经删除"
      if !@photo.school_id.blank?
        redirect_to school_url(@photo.school_id)
      elsif !@photo.activity_id.blank?
        redirect_to activity_url(@photo.activity_id)
      elsif !@photo.requirement_id.blank?
        redirect_to school_requirement_path(@photo.requirement.school_id, @photo.requirement_id)
      else
        redirect_to user_url(@photo.user_id)
      end
    else
      render_404
    end
  end
  
  
  def show
    @photo = Photo.find(params[:id])
    @photo.user_id = 1 if @photo.user.nil?
  end
end
