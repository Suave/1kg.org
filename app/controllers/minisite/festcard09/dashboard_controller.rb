class Minisite::Festcard09::DashboardController < ApplicationController
  include StuffUtil
  before_filter :find_requirement_type, :only => [:index, :password, :comment, :love_message, :messages]
  
  def index
    @group = Group.find_by_slug('postcard')
    @board = @group.discussion.board
    
    @for_team_bucks   = @requirement_type.requirements.for_team_donations.find :all, :include => [:school]
    render :action => "new"
  end
  
  def cards
    # 贺卡设计展示
  end
  
  def password
    return set_message_and_redirect_to_index("请输入爱心密码, 点击提交按钮") if params[:password].blank?

    @donation = @requirement_type.donations.find_by_code(params[:password])

    if @donation.blank?
      return set_message_and_redirect_to_index("您的密码不正确")
    elsif @donation.matched?
      if @donation.auto_fill?
        return set_message_and_redirect_to_index("您的密码已过期，系统自动匹配给#{@donation.requirement.school.title}学校")
      else
        return set_message_and_redirect_to_index("您的密码已配过对了")
      end
    else
      @requirements = @requirement_type.requirements.find :all, :include => [:school], :conditions => ["matched_count < quantity"]
      render :action => "write_comment"
    end
  end
  
  def comment    
    @donation = @requirement_type.donations.find_by_code params[:token]
    @requirements = @requirement_type.requirements.find :all, :include => [:school], :conditions => ["matched_count < quantity"]
    
    if params[:requirement].blank?
      flash[:notice] = "请选择一所学校"
      render :action => "write_comment"
      return
    end
    
    if logged_in?
      # logged in
      update_donation
      
    elsif params[:status] == 'login'
      # login
      self.current_user = User.authenticate(params[:login_email], params[:login_password])
      if logged_in?
        update_donation
      else
        flash[:notice] = "邮件地址或密码错误"
        render :action => "write_comment"
      end
      
    elsif params[:status] == 'signup'
      # auto singup a default user
      cookies.delete :auth_token
      @user = User.new(:email => params[:email], :login => params[:login], :password => params[:password], :password_confirmation => params[:password_confirmation])
      @user.register! if @user.valid?
      if @user.errors.empty?
        @user.activate!
        
        # 发邮件通知用户
        Mailer.deliver_create_default_user_for_mooncake(@user, params[:password])
        
        self.current_user = @user
                
        update_donation
      else
        flash[:notice] = @user.errors[:email]
        render :action => 'write_comment'
      end
      
    else
      flash[:notice] = "请填写您的用户信息"
      render :action => "write_comment"
    end
  end
  
  private
  def index_path
    minisite_festcard09_index_url
  end
  
  def find_requirement_type
    @requirement_type = RequirementType.find_by_slug("festcard09")
  end
  
  def update_donation
    requirement = Requirement.find params[:requirement][:id]
    @donation.user = self.current_user
    @donation.requirement = requirement
    @donation.school = requirement.school
    @donation.matched_at = Time.now
    @donation.comment = params[:comment]
    Donation.transaction do 
      @donation.save!
      requirement.update_attributes!(:matched_count => Donation.count(:all, :conditions => ["school_id=? and buck_id=?", @donation.school, requirement.id]))
    end
    
    if params[:join] == "1"
      @group = Group.find_by_slug('mooncake')
      @group.members << self.current_user unless @group.joined?(self.current_user)
    end
    flash.discard
  end  
end