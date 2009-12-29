require 'digest/md5'
require 'cgi'
require 'iconv'

module Donation
  class Request
    GATEWAY_URL = "/gateway/receiveMerchantInfo"
    PARAMS = %w(inputCharset bgUrl signType buyerName buyerEmail orderId orderTime productSerial productNumber pid)
    
    def initialize(return_url, buyer_name, buyer_email, order_id, product_serial, product_number, pid, key, order_time = Time.now)
      @return_url = return_url
      @buyer_name = buyer_name
      @buyer_email = buyer_email
      @order_id = order_id
      @order_time = order_time.strftime("%Y%m%d%H%M%S")
      @product_serial = product_serial
      @product_number = product_number
      @pid = pid
      @key = key
    end
    
    def url
      "#{GATEWAY_URL}?#{params}&signMsg=#{sign_msg}"
    end
    
    def params
      PARAMS.collect do |param|
        value = send(param.underscore)
        value == '' ? nil : "#{param}=#{CGI.escape(value)}"
      end.compact.join('&')
    end
    
    def sign_params
      params = PARAMS + ['key']
      params.map do |param|
        value = send(param.underscore)
        value == '' ? nil : "#{param}=#{value}"
      end.compact.join('&')
    end
    
    def sign_msg
      Digest::MD5.hexdigest(sign_params).upcase
    end
    
    def input_charset; '1'; end
    def bg_url; @return_url; end
    def sign_type; '1'; end
    def buyer_name; @buyer_name; end
    def buyer_email; @buyer_email; end
    def order_id; @order_id; end
    def order_time; @order_time; end
    def product_serial; @product_serial; end
    def product_number; @product_number; end
    def pid; @pid; end
    def key; @key; end
    
    def logger
        RAILS_DEFAULT_LOGGER
    end
  end
  
  class Response
    SIGN_PARAMS = %w(orderId orderTime dealId dealTime payResult errCode donationUrl key)
    def initialize(params, key)
      @params = params
      @key = key
    end
    
    def successful?
      pay_result == '10' && valid_sign?
    end
    
    def valid_sign?
      logger.info("sign_msg: #{sign_msg}")
      logger.info("digest: #{Digest::MD5.hexdigest(sign_params).upcase}")
      logger.info("sign_params: #{sign_params}")
      sign_msg == Digest::MD5.hexdigest(sign_params).upcase
    end

    def sign_params
      SIGN_PARAMS.map do |param|
        value = send(param.underscore)
        value == '' ? nil : "#{param}=#{value}" 
      end.compact.join('&')
    end
    
    def order_id; @params[:orderId]; end
    def order_time; @params[:orderTime]; end
    def deal_id; @params[:dealId]; end
    def deal_time; @params[:dealTime]; end
    def pay_result; @params[:payResult]; end
    def err_code; @params[:errCode].blank? ? '' : params[:errCode]; end
    def key; @key; end
    def donation_url; @params[:donationUrl]; end
    def sign_msg; @params[:signMsg]; end
    
    def logger
        RAILS_DEFAULT_LOGGER
    end
  end
  
  class RequestValidate
    SIGN_PARAMS = %w(inputCharset bgUrl signType buyerName buyerEmail orderId orderTime productSerial productNumber pid key)
        
    def initialize(params, key)
      @params = params
      @key = key
    end
    
    def valid_sign?
      sign_msg == Digest::MD5.hexdigest(sign_params).upcase
    end

    def sign_params
      SIGN_PARAMS.map do |param|
        value = send(param.underscore)
        value == '' ? nil : "#{param}=#{value}" 
      end.compact.join('&')
    end
    
    def input_charset;      @params[:inputCharset]; end
    def bg_url;             @params[:bgUrl]; end
    def sign_type;          @params[:signType]; end
    def buyer_name;         @params[:buyerName]; end
    def buyer_email;        @params[:buyerEmail]; end
    def order_id;           @params[:orderId]; end
    def order_time;         @params[:orderTime]; end
    def product_serial;     @params[:productSerial]; end
    def product_number;     @params[:productNumber]; end
    def pid;                @params[:pid]; end
    def key; @key; end
    def sign_msg; @params[:signMsg]; end
    
    def logger
        RAILS_DEFAULT_LOGGER
    end
  end
  
  class RequestResult
    PARAMS = %w(orderId orderTime dealId dealTime payResult errCode donationUrl)
    
    def initialize(redirect_url, order_id, order_time, deal_id, deal_time, pay_result, donation_url, key)
      @redirect_url = redirect_url
      @order_id = order_id.to_s
      @order_time = order_time
      @deal_id = deal_id.to_s
      @deal_time = deal_time.strftime("%Y%m%d%H%M%S")
      @pay_result = pay_result
      @donation_url = donation_url
      @key = key
    end
    
    def url
      "#{redirect_url}?#{params}&signMsg=#{sign_msg}"
    end
    
    def params
      PARAMS.collect do |param|
        value = send(param.underscore)
        #logger.info "#{param}=#{CGI.escape(value)}"
        value == '' ? nil : "#{param}=#{CGI.escape(value)}"
      end.compact.join('&')
    end
    
    def sign_params
      params = PARAMS + ['key']
      params.map do |param|
        value = send(param.underscore)
        value == '' ? nil : "#{param}=#{value}"
      end.compact.join('&')
    end
    
    def sign_msg
      Digest::MD5.hexdigest(sign_params).upcase
    end
    
    def redirect_url; @redirect_url; end
    def order_id; @order_id; end
    def order_time; @order_time; end
    def deal_id; @deal_id; end
    def deal_time; @deal_time; end
    def pay_result; @pay_result ? '10' : '11'; end
    def err_code; @pay_result ? '' : '00000'; end
    def key; @key; end
    def donation_url; @donation_url; end
    
    def logger
        RAILS_DEFAULT_LOGGER
    end
  end
end