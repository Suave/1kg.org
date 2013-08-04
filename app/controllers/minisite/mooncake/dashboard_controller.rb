# -*- encoding : utf-8 -*-
#require 'uuid'

class Minisite::Mooncake::DashboardController < ApplicationController
  include StuffUtil
  before_filter :login_required, :except => [:index, :password, :comment, :love_message, :donors, :messages]
  before_filter :find_requirement_type, :only => [:index, :password, :comment, :love_message, :messages]
  def index
    @group = Group.find_by_slug('mooncake')
  
    @requirements = @requirement_type.requirements
    # for love message
    @donation = @requirement_type.donations.find(:first, :conditions => ["matched_at is not null"], :order => "matched_at desc")
    session[:random_donation] = (@donation.nil? ? nil : @donation.id)
    render :action => "new"
  end
  
  def love_message
        
    unless session[:random_donation].nil?
      @donation = @requirement_type.donations.find(:first, :conditions => ["matched_at is not null and id < ? and auto_fill = ?", session[:random_donation].to_i, false], :order => "id desc")
    end
    
    @donation = @requirement_type.donations.find(:first, :conditions => ["matched_at is not null and auto_fill = ?", false], :order => "matched_at desc" ) if @donation.nil?
    
    session[:random_donation] = (@donation.nil? ? nil : @donation.id)
    
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
      #return set_message_and_redirect_to_index("太好了！还没配对")
      #if logged_in?
        render :action => "write_comment"
      #else
        # 提示登录或注册
      #end
    end
=begin    
    flash[:notice] = "密码配对功能9月10日启用"
    redirect_to index_path
=end
  end
  
  def comment
    @donation = @requirement_type.donations.find_by_code params[:token]
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
        Mailer.deliver_create_default_user_for_mooncake(@user)
        
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
  
  def messages
    @donations = @requirement_type.donations.paginate :page => params[:page] || 1, 
                                          :conditions => ["comment is not null"], 
                                          :order => "matched_at desc",
                                          :per_page => 30
  end
  
  def donors
    @school = School.find(params[:id])
    @donations = Donation.paginate :page => params[:page] || 1,
                             :conditions => ["school_id = ?", params[:id]],
                             :order => "matched_at desc",
                             :per_page => 30
  end
  
  private
  def index_path
    minisite_mooncake_index_url
  end
  
  def find_requirement_type
    @requirement_type = RequirementType.find_by_slug("mooncake")
  end
  
  def update_donation
    @donation.user = self.current_user
    @donation.school = @donation.requirement.school
    @donation.matched_at = Time.now
    @donation.comment = params[:comment]
    Donation.transaction do 
      @donation.save!
      @donation.requirement.update_attributes!(:matched_count => Donation.count(:all, :conditions => ["school_id=? and buck_id=?", @donation.school, @donation.requirement.id]))
    end
    
    if params[:join] == "1"
      @group = Group.find_by_slug('mooncake')
      @group.members << self.current_user unless @group.joined?(self.current_user)
    end
    flash.discard
  end

end
