# -*- encoding : utf-8 -*-
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
    @photo = Photo.new(:photoable_id => params[:photoable_id],:photoable_type => params[:photoable_type])
    @photo.photoable_id = params[:photoable_id]
    @photo.photoable_type = params[:photoable_type]
  end
  
  def edit
    @photo = Photo.find(params[:id])
    @photo.photoable_id = params[:photoable_id]
    @photo.photoable_type = params[:photoable_type]
  end
  
  def create
    @photo = current_user.photos.build(params[:photo])
    if @photo.save
      flash[:notice] = "照片上传成功!" 
      respond_to do |wants|
        if @photo.photoable.present?
          wants.html {redirect_to url_for(@photo.photoable)}
        else
          wants.html {render 'insert', :layout => false}
        end
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
    @photo = Photo.find(params[:id])
    @photo.update_attributes(params[:photo])
    @photo.save if @photo.owned_by?(current_user)
    redirect_to @photo
  end
  
  def destroy
    @photo = Photo.find(params[:id])
    if @photo.owned_by?(current_user)
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
    @photos = @photo.photoable.photos - [@photo] unless @photo.photoable.nil?
    @photo.user_id = 1 if @photo.user.nil?
  end
end
