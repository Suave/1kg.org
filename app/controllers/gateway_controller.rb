require 'digest/md5'
require 'cgi'
require 'iconv'

class GatewayController < ApplicationController
  def receive_merchant_info
    @vendor = Vendor.find_by_slug(params[:pid])

    if @vendor 
      key = @vendor.sign_key
      amount = params[:productNumber].to_i
      @request = Onekg::RequestValidate.new(params, key)
      @requirement_type = RequirementType.find_by_slug(params[:productSerial])
      
      if @request.valid_sign? || @requirement_type.nil?
        @donation = @vendor.donations.find_by_order_id(params[:orderId])

        if @donation && @donation.matched_at
          flash[:notice] = "您已经完成了此笔捐赠，非常感谢您的参与！"
          redirect_to donations_path
        elsif @donation
          redirect_to "http://www.1kg.org/donations/new?code=#{@donation.code}"
        else
          # 生成密码
          while 1
            stuff_password = UUID.create_random.to_s.gsub("-", "").unpack('axaxaxaxaxaxaxax').join('')
            break unless exist_stuff = Donation.find_by_code(stuff_password)
          end

          # 生成捐赠
          @donation = Donation.new(:code => stuff_password,
                             :vendor_id => @vendor.id,
                             :type_id => @requirement_type.id,
                             :order_id => params[:orderId],
                             :order_time => params[:orderTime],
                             :product_serial => params[:productSerial],
                             :product_number => amount,
                             :buyer_name => params[:buyerName],
                             :buyer_email => params[:buyerEmail],
                             :deal_id => Time.now.to_i)

          @donation.save!
          redirect_to "http://www.1kg.org/donations/new?code=#{@donation.code}"
          #Mailer.deliver_donation(params[:buyerName], params[:buyerEmail], @donation_url)
        end
      else
        flash[:notice] = '对不起，无效的请求'
        redirect_to donations_path
      end
    else
      flash[:notice] = '对不起，商家不存在'
      redirect_to donations_path
    end
  end
end