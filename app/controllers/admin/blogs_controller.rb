class Admin::BlogsController < Admin::BaseController
  def index
    @blogs = Blog.all()
  end
  
  def new
    @blog = Blog.new
  end
  
  def edit
    @blog = Blog.find params[:id]
  end
  
  def create
    @blog = Blog.new params[:blog]
    @blog.user = current_user
    @blog.save!
    flash[:notice] = "<p>博客发布成功</p>"
    redirect_to admin_blogs_url()
  end
  
  def update
    @blog = Blog.find(params[:id])
    @blog.update_attributes!(params[:blog])
    flash[:notice] = "博客修改成功"
    redirect_to admin_blogs_url()
  end
  
  def destroy
    @blog = Blog.find(params[:id])
    @blog.destroy
    flash[:notice] = "博客删除成功"
    redirect_to admin_blogs_url
  end
end
  