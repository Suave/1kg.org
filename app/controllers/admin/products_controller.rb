class Admin::ProductsController < Admin::BaseController
  def index
    @products = Product.find :all, :order => "id desc"
  end
  
  def new
    @product = Product.new
  end
  
end