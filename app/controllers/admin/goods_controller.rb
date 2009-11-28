class Admin::GoodsController < Admin::BaseController
  before_filter :find_good, :except => [:index, :create, :new]
  def index
    @goods = Good.find :all, :order => "id desc"
  end
  
  def new
    @good = Good.new
  end
  
  def create
    @good = Good.new params[:good]
    @good.user = current_user
    @good.save!
    flash[:notice] = "商品添加成功"
    redirect_to admin_goods_url
  end
  
  def edit
  end
  
  def update
    @good.update_attributes!(params[:good])
    flash[:notice] = "商品修改成功"
    redirect_to admin_goods_url
  end
  
  private
  def find_good
    @good = Good.find params[:id]
  end
  
  
end