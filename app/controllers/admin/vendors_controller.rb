# -*- encoding : utf-8 -*-


class Admin::VendorsController < Admin::BaseController
  def index
    @vendors = Vendor.find :all, :order => "id desc"
  end
  
  def new
    @vendor = Vendor.new
  end
  
  def create
    # 创建 vendor 时 生成 sign_key, 可以用 sha1(sign+Time.now)
    @vendor = Vendor.new params[:vendor]
    @vendor.save!
    flash[:notice] = "<p>成功添加厂商：#{@vendor.title}</p><p>KEY: #{@vendor.sign_key}</p>"
    redirect_to admin_vendors_url
  end
  
  def edit
    
  end
  
  def update
    # 更新时不能更新 sign_key
  end
  
  
end
