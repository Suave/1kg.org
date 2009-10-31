class Admin::GoodsController < Admin::BaseController
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
    @good = Good.find params[:id]
  end
  
  def update
    
  end
  
  
  
end