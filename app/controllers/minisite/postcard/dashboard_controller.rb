require 'uuid'

class Minisite::Postcard::DashboardController < ApplicationController
  before_filter :login_required, :except => [:index, :love_message]
  
  def index
    @board = PublicBoard.find_by_slug("postcard").board
    @topics = @board.topics.find(:all, :order => "sticky desc, last_replied_at desc", :limit => 10)
    
    postcard = RequirementType.find_by_slug("postcard")
    
    @for_public_bucks = postcard.requirements.for_public_donations.find :all, :include => [:school]
    @for_team_bucks   = postcard.requirements.for_team_donations.find :all, :include => [:school]
    
    school_ids = (@for_public_bucks.collect {|b| b.school.id} + @for_team_bucks.collect {|b| b.school.id}).uniq
    
    @school_topics = SchoolBoard.find(:all, :conditions => ["school_id in (?)", school_ids]).collect {|sb| sb.board.topics}.flatten

    @photos = Photo.find(:all, :conditions => ["school_id in (?)", school_ids], :limit => 10, :order => "created_at desc")
    
    @donation = postcard.donations.find(:first, :conditions => ["matched_at is not null and user_id is not null"], :order => "matched_at desc")
    @total_donation_count = postcard.donations.count(:all, :conditions => ["matched_at is not null and school_id is not null"])
    session[:random_donation] = @donation.id
  end
  
  def love_message
    postcard = RequirementType.find_by_slug("postcard")
        
    unless session[:random_donation].nil?
      @donation = postcard.donations.find(:first, :conditions => ["matched_at is not null and user_id is not null and id < ?", session[:random_donation].to_i], :order => "id desc")
    end
    
    @donation = postcard.donations.find(:first, :conditions => ["matched_at is not null"], :order => "matched_at desc" ) if @donation.nil?
    
    session[:random_donation] = @donation.id
    
  end
  
  
  def password
    if params[:password].blank?
      set_message_and_redirect_to_index "请输入贺卡上的爱心密码, 点击验证按钮"
    else
      
      if @donation = Donation.find_by_code(params[:password], :conditions => ["school_id is not null"])
        # 已成功配对
        set_message_and_redirect_to_index "此贺卡捐赠的图书已送到#{@donation.school.title}"
        
      elsif @donation = Donation.find_by_code(params[:password], :conditions => ["matched_at is null"])
        # 尚未配对
        postcard = StuffType.find_by_slug("postcard")
        
        @for_public_bucks = postcard.requirements.for_public_donations.find :all, :include => [:school], :conditions => ["matched_count < quantity"] 
        @for_team_bucks   = postcard.requirements.for_team_donations.find :all, :include => [:school], :conditions => ["matched_count < quantity"]
         
        render :action => "school_list"
        
      else
        set_message_and_redirect_to_index("密码错误，请重新输入")
        
      end

    end
  end
  
  def give
    if @donation = Donation.find_by_code(params[:token], :conditions => ["matched_at is not null and user_id=?", current_user])
      # 用户用密码验证了第二次
      flash[:notice] = "您已选择#{@donation.school.title}学校，写两句话给学校和孩子们吧 ;)"
      render :action => "write_comment"
      
    elsif @donation = Donation.find_by_code(params[:token], :conditions => ["matched_at is null"]) 
      # 重复密码，有用户来验证
      @requirement = Requirement.find(params[:id])
      @donation.user = current_user
      @donation.school = @requirement.school
      @donation.matched_at = Time.now
      Donation.transaction do 
        @donation.save!
        @requirement.update_attributes!(:matched_count => Donation.count(:all, :conditions => ["school_id=?", @donation.school]))
        session[:pc_code] = params[:token]
        session[:pc_user_id] = current_user.id
      end
      flash[:notice] = "密码配对成功，您捐给#{@donation.school.title}一本书。写两句话给学校和孩子们吧 ;)"
      render :action => "write_comment"
      
    else
      # 密码不正确
      set_message_and_redirect_to_index("密码错误，请重新输入")
    end
    
  end
  
  def comment
    @donation = Donation.find_by_code(params[:token], :conditions => ["matched_at is not null and user_id=?", current_user] )
    set_message_and_redirect_to_index("密码错误，请重新输入") if @donation.blank?
    
    unless @donation.user == current_user
      flash[:notice] = "您不是这张卡的主人，不能写留言"
      redirect_to minisite_postcard_index_url
      return
    end
    

    @donation.comment = params[:comment]
    @donation.save!
    
    if params[:join] == "1"
      @group = Group.find(38)
      @group.members << current_user unless @group.joined?(current_user)
    end
    
    flash[:notice] = "谢谢您的支持！"
    redirect_to minisite_postcard_index_url
    

  end
  
  def messages
    @donations = Donation.paginate :page => params[:page] || 1, 
                             :conditions => ["comment is not null"], 
                             :order => "matched_at desc",
                             :per_page => 30
  end
  
  def donors
    @school = School.find(params[:id])
    postcard = RequirementType.find_by_slug("postcard")
    @donations = postcard.donations.paginate :page => params[:page] || 1,
                             :conditions => ["school_id = ? and user_id is not null", params[:id]],
                             :order => "matched_at desc",
                             :per_page => 30
    @auto_donation_count = postcard.donations.count(:all, :conditions => ["school_id = ? and user_id is null", params[:id]])
  end
  
  
  private
  def set_message_and_redirect_to_index(msg = "")
    flash[:postcard_notice] = msg
    redirect_to minisite_postcard_index_url
    return
  end
  
end