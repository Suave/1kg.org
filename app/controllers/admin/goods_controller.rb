require 'md5'

class Admin::GoodsController < Admin::BaseController
  before_filter :find_good, :except => [:index, :create, :new, :sale, :sending, :successful]
  
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
  
  def recommend
    @good.toggle!(:recommend)
    redirect_to admin_goods_url
  end
  
  def sale
  end
  
  def sending
    check_sale_form
    
    @request = Donation::Request.new( "/admin/goods/successful", 
                                      params[:buyer],
                                      params[:email],
                                      params[:order_id], 
                                      params[:product_id], 
                                      params[:product_number],
                                      params[:vendor_id],
                                      Vendor.find_by_slug(params[:vendor_id]).sign_key
                                    )
    redirect_to @request.url
    
  end
  
  def successful
    logger.info("successful: #{params}")
    @response = Donation::Response.new(params, Vendor.find_by_slug("AJXY").sign_key)
    if @response.successful?
      # 返回发送成功的信息
      render :action => "successful"
    else
      # 失败信息
      render :action => "fail"
    end
    
  end
  
  
  private
  def find_good
    @good = Good.find params[:id]
  end
  
  def check_sale_form
    ps = ["buyer", "email", "order_id", "product_id", "product_number"]
    ps.each do |p|
      flash[:notice] = "所有项目必填"
      return render :action => "sale" if params[p].blank?
    end
  end
  
  
end