class DonationsController < ApplicationController
  def index
    @requirements = RequirementType.exchangable.map(&:requirements).sum
  end
  
  def new
    @donation = Donation.find_by_code(params[:code])
    
    respond_to do |want|
      if @donation && @donation.matched_at.nil?
        @requirement_type = @donation.requirement_type
        @requirements = @requirement_type.requirements
        
        flash[:notice] = '恭喜您，密码匹配成功！'
        session[:donation_code] = params[:code]
        want.html {render 'new'}
      elsif @donation && @donation.matched_at?
        flash[:notice] = "对不起，您已经完成了匹配"
        want.html { redirect_to donations_path }
      else
        flash[:notice] = "对不起，您输入的密码不正确"
        want.html { redirect_to donations_path }
      end
    end
  end
  
  def update
    @donation = Donation.find_by_code(session[:donation_code])

    respond_to do |want|
      if @donation && @donation.requirement_type
        @requirement_type  = @donation.requirement_type
        @requirement  = @requirement_type.requirements.find(params[:requirement_id])

        if @requirement
          # 更新用户捐赠信息
          @donation.school_id = @requirement.school_id
          @donation.buck_id = @requirement.id
          @donation.matched_at = Time.now

          Donation.transaction do
            @donation.save!
            @requirement.update_attributes!(:matched_count => @requirement.donations.matched.sum(:product_number))
          end
          flash[:notice] = "密码配对成功，您捐给#{@donation.school.title}一个#{@requirement_type.title}。写两句话给学校和孩子们吧 ;)"
          want.html{redirect_to commenting_donation_path}
        else
          flash[:notice] = "对不起，您选择的学校不存在，请重新选择"
          want.html{render 'new'}
        end
      else
        flash[:notice] = "对不起，请先输入您的赠送密码"
        want.html { redirect_to donations_path }
      end
    end
  end
  
  def commenting
    @donation = Donation.find_by_code(session[:donation_code])
  end
  
  def comment
    @donation = Donation.find_by_code(session[:donation_code])
    
    respond_to do |want|
      if @donation
        @donation.comment = params[:message]
        @donation.save
        flash[:notice] = '非常感谢您的参与！'
        session[:donation_code] = nil
        want.html{redirect_to donations_path}
      else
        flash[:notice] = '对不起，请您先输入密码'
        want.html{redirect_to donations_path}
      end
    end
  end
end