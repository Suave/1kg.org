class Admin::GroupsController < Admin::BaseController
  before_filter :find_group, :except => [:index, :create]
  
  def index
    @groups = Group.find(:all, :order => "created_at desc")
  end
  
  def new
    
  end
  
  def create
    @group = Group.new(params[:group])
    @group.creator = current_user
    @group.save!
    flash[:notice] = "小组创建成功"
    redirect_to admin_groups_url
  end
  
  def edit
    
  end
  
  def update
    @group.update_attributes!(params[:group])
    flash[:notice] = "小组修改已保存"
    redirect_to admin_groups_url
  end
  
  
  
  private
  def find_group
    @group = params[:id].blank? ? Group.new : Group.find(params[:id])
  end
  
  
end