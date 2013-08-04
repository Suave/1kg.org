# -*- encoding : utf-8 -*-
class Admin::PagesController < Admin::BaseController

  uses_tiny_mce :options => TINYMCE_OPTIONS, :only => [:new, :create, :edit, :update]
  
  def index
    @pages = Page.find(:all)
  end
  
  def new
    @page = Page.new
  end
  
  def create
    @page = Page.new(params[:page])
    write_last_modified @page
    @page.save!
    flash[:notice] = "\"#{@page.title}\" 添加成功"
    redirect_to admin_pages_url
  end
  
  def edit
    @page = Page.find_by_slug(params[:id])
  end
  
  def update
    @page = Page.find_by_slug(params[:id])
    write_last_modified @page
    @page.update_attributes!(params[:page])
    flash[:notice] = "\"#{@page.title}\" 编辑成功"
    redirect_to admin_pages_url
  end
  
  def destroy
    @page = Page.find_by_slug(params[:id])
    @page.destroy
    flash[:notice] = "\"#{@page.title}\" 删除成功!"
    redirect_to admin_pages_url
  end
  
  
  private 
  def write_last_modified(page)
    page.last_modified_at = Time.now
    page.last_modified_by = current_user
  end
end
