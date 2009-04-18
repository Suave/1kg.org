class Admin::StuffBucksController < Admin::BaseController
  before_filter :find_stuff_type
  
  def index
    @bucks = @type.bucks.find :all, :order => "created_at desc"
  end
  
  def new
    @buck = StuffBuck.new
  end
  
  def create
    @buck = StuffBuck.new(params[:buck])
    @buck.type = @type
    @buck.save!
    flash[:notice] = "Buck 创建成功"
    redirect_to admin_stuff_type_bucks_url(@type)
  end
  
  def edit
    @buck = StuffBuck.find(params[:id])
  end
  
  def update
    @buck = StuffBuck.find(params[:id])
    @buck.update_attributes!(params[:buck])
    flash[:notice] = "Buck 更新成功"
    redirect_to admin_stuff_type_bucks_url
  end
  
  def destroy
    @buck = StuffBuck.find(params[:id])
    @buck.destroy
    flash[:notice] = "Buck 删除成功"
    redirect_to admin_stuff_type_bucks_url
  end
  
  def show
    @buck = StuffBuck.find(params[:id])
    @stuffs = @buck.stuffs.find :all, :include => [:user, :school]
  end
  
  
  
  
  private
  def find_stuff_type
    @type = StuffType.find(params[:stuff_type_id])
  end
  
end