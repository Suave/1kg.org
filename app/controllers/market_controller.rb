class MarketController < ApplicationController
  def index
  end
  
  def validate
    @password = params[:password]
    @donation = Donation.find_by_code(params[:password])
    @type = @donation.type
    @bucks = @donation.type.bucks
    @product = Product.find_by_serial(@donation.product_serial)
    
    flash[:notice] = '恭喜您，密码匹配成功！'
  end
  
  def denote
    @donation = Donation.find_by_code(params[:password])
    @type  = @donation.type
    @buck  = DonationBuck.find(params[:buck_id])

    @donation.school_id = @buck.school_id
    @donation.buck_id = @buck.id
    @donation.matched_at = Time.now
    Donation.transaction do
      @donation.save!
      @buck.update_attributes!(:matched_count => @buck.donations.matched.count)
    end

    flash[:notice] = "密码配对成功，您捐给#{@donation.school.title}一本书。写两句话给学校和孩子们吧 ;)"
    session[:donation_id] = @donation.id
  end
  
  def message
    @donation = Donation.find(session[:donation_id])
    @donation.comment = params[:message]
    @donation.save
    
    flash[:notice] = '非常感谢您的参与！'
    
    # Todo: 此处应该返回商家网站
    redirect_to '/market'
  end
end