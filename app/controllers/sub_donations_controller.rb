class SubDonationsController < ApplicationController
  before_filter :login_required
  before_filter :set_co_donation
  
  def index
    @sub_donations = @co_donation.sub_donations.paginate(:per_page => 20, :page => params[:page], :order => "updated_at DESC")
    respond_to do |wants|
      if current_user.id == @co_donation.user_id
        wants.html
      else
        flash[:notice] = '对不起，您没有足够的权限查看此页面'
        wants.html {redirect_to @co_donation}
      end
    end
  end
  
  def create
    @sub_donation = @co_donation.sub_donations.build(params[:sub_donation])
    @sub_donation.user_id = current_user.id
    
    respond_to do |wants|
      if @sub_donation.save
         
        message = Message.new(:subject => "你为#{@co_donation.school.title}认捐了#{@sub_donation.quantity}件#{@co_donation.goods_name}，请继续跟进",
                                :content => "<p>你好，#{@sub_donation.user.login}:</p><br/><p>你认捐了的团捐“#{@co_donation.title}”，请在一周内，将捐赠物资邮寄或快递给接收人，并在网站上上可以传证明物资已发出的单据照片。<br/><br/>证明照片在团捐页面上传，并且在上传照片前你可以修改捐赠数量和取消捐赠。<br/>地址 => http://www.1kg.org/co_donations/#{@co_donation.id} </p><br/><p>多背一公斤团队</p>"
                                )
        message.author_id = 0
        message.to = [@co_donation.user]
        message.save!
        
        wants.html { redirect_to co_donation_path(@co_donation)}
      else
        flash[:notice] = "捐赠数量修改错误"
        wants.html {redirect_to @co_donation}
      end
    end
  end
  
  def prove
    @sub_donation = @co_donation.sub_donations.find(params[:id])
    respond_to do |wants|
      if @sub_donation.update_attributes(params[:sub_donation]) && !@sub_donation.image_file_name.nil?
        @sub_donation.prove
        message = Message.new(:subject => "#{@sub_donation.user.login}为#{@co_donation.school.title}捐赠了#{@sub_donation.quantity}件#{@co_donation.goods_name}",
                            :content => "<p>你好，#{@co_donation.user.login}:</p><br/><p>你发起的团捐“#{@co_donation.title}”，得到了#{@sub_donation.user.login}的捐赠。<br/><br/>请对#{@sub_donation.user.login}的捐赠证明和实际物资接收情况进行确认：<br/>使用你的帐号登录一公斤网站，在你的团捐页面里你会看到每条已寄出的捐赠记录下都有可以确定状态的选项，请针对实际情况选择合适的选项，并适时更新。<br/>地址 => http://www.1kg.org/co_donations/#{@co_donation.id} </p><br/><p>多背一公斤团队</p>"
                            )
        message.author_id = 0
        message.to = [@co_donation.user]
        message.save!
        wants.html { redirect_to @co_donation}
      else
        flash[:notice] = "照片上传出错"
        wants.html {redirect_to(co_donation_url(@co_donation) + "?error=prove") }
      end
    end
  end
  
  def update
    @sub_donation = @co_donation.sub_donations.find(params[:id])
    
    respond_to do |wants|
      if @sub_donation.update_attributes(params[:sub_donation])
        wants.html { redirect_to @co_donation}
      else
        flash[:notice] = "捐赠数量修改错误"
        wants.html { redirect_to @co_donation}
      end
    end
  end
  
  def admin_state
      @sub_donation = @co_donation.sub_donations.find(params[:id])
      if ['miss','receive','refuse','wait'].include?(params[:sub_donation][:action])
        eval("@sub_donation.#{params[:sub_donation][:action]}")
      end
      if ['miss','receive','refuse'].include?(params[:sub_donation][:action])
        message_to_donor(params[:sub_donation][:action])
      end
    redirect_to @co_donation
  end
  
  def destroy
    @sub_donation = @co_donation.sub_donations.find(params[:id])
    @sub_donation.destroy
    
    respond_to do |wants|
      flash[:notice] = "你的捐赠已经取消"
      wants.html { redirect_to @co_donation}
    end  
  end
  
  private
   
  def update_co_donation
    @co_donation.update_number!    
  end
  
  def set_co_donation
    @co_donation = CoDonation.find(params[:co_donation_id])
  end
  
  #为修改状态发送的站内信
  def message_to_donor(state)
    text= {'miss' => ["接收人没有收到你为#{@co_donation.school.title}捐赠的#{@sub_donation.quantity}件#{@co_donation.goods_name}","<p>你好，#{@sub_donation.user.login}:</p><br/><p>由于某些原因，接收人没有收到你的捐赠,你可以联系接收人和你使用的物流公司或邮局去了解详情。<br/>团捐页面的地址 => http://www.1kg.org/co_donations/#{@co_donation.id} <br/>不论如何,仍然感谢你的捐赠! :)</p><br/><p>多背一公斤团队</p>"],
     'receive' => ["接收人收到了你为#{@co_donation.school.title}捐赠的#{@sub_donation.quantity}件#{@co_donation.goods_name}","<p>你好，#{@sub_donation.user.login}:</p><br/><p>接收人收到了你的捐赠，谢谢你对#{@co_donation.school.title}的帮助。<br/>去团捐页面看看吧：<br/>地址 => http://www.1kg.org/co_donations/#{@co_donation.id} </p><br/><p>多背一公斤团队</p>"],
     'refuse' => ["你为#{@co_donation.school.title}捐赠的#{@sub_donation.quantity}件#{@co_donation.goods_name}失效了","<p>你好，#{@sub_donation.user.login}:</p><br/><p>由于团捐组织者认为你的捐赠证明不符合要求，你的捐赠失效了。<br/>团捐页面地址 => http://www.1kg.org/co_donations/#{@co_donation.id} </p><br/><p>多背一公斤团队</p>"]
     }[state]
    
    message = Message.new(:subject => text[0],
                                :content => text[1]
                                )
    message.author_id = 0
    message.to = [@sub_donation.user]
    message.save!
  end

end