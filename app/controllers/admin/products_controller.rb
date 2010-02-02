class Admin::ProductsController < Admin::BaseController
  def index
    @products = Product.find :all, :order => "id desc"
  end
  
  def new
    @product = Product.new
    @product.vendor = Vendor.find params[:vendor_id]
  end
  
  def create
    @product = Product.new params[:product]
    @product.save!
    flash[:notice] = "成功添加 #{@product.vendor.title} 的商品"
    redirect_to admin_vendors_url
  end
  
end