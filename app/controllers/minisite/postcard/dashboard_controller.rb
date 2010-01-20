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
    
    @stuff = postcard.donations.find(:first, :conditions => ["matched_at is not null"], :order => "matched_at desc")
    session[:random_stuff] = @stuff.id
  end
  
  def love_message
    postcard = StuffType.find_by_slug("postcard")
        
    unless session[:random_stuff].nil?
      @stuff = postcard.stuffs.find(:first, :conditions => ["matched_at is not null and id < ?", session[:random_stuff].to_i], :order => "id desc")
    end
    
    @stuff = postcard.stuffs.find(:first, :conditions => ["matched_at is not null"], :order => "matched_at desc" ) if @stuff.nil?
    
    session[:random_stuff] = @stuff.id
    
  end
  
  
  def password
    if params[:password].blank?
      set_message_and_redirect_to_index "请输入贺卡上的爱心密码, 点击验证按钮"
    else
      
      if @stuff = Donation.find_by_code(params[:password], :conditions => ["matched_at is not null and user_id=?", current_user])
        # 已成功配对
        set_message_and_redirect_to_index "您这张贺卡已经选过学校"
        
      elsif @stuff = Donation.find_by_code(params[:password], :conditions => ["matched_at is null"])
        # 尚未配对
        postcard = StuffType.find_by_slug("postcard")
        
        @for_public_bucks = postcard.bucks.for_public_donations.find :all, :include => [:school], :conditions => ["matched_count < quantity"] 
        @for_team_bucks   = postcard.bucks.for_team_donations.find :all, :include => [:school], :conditions => ["matched_count < quantity"]
         
        render :action => "school_list"
        
      else
        set_message_and_redirect_to_index("密码错误，请重新输入")
        
      end

    end
  end
  
  def give
    if @stuff = Donation.find_by_code(params[:token], :conditions => ["matched_at is not null and user_id=?", current_user])
      # 用户用密码验证了第二次
      flash[:notice] = "您已选择#{@stuff.school.title}学校，写两句话给学校和孩子们吧 ;)"
      render :action => "write_comment"
      
    elsif @stuff = Donation.find_by_code(params[:token], :conditions => ["matched_at is null"]) 
      # 重复密码，有用户来验证
      @buck = StuffBuck.find(params[:id])
      @stuff.user = current_user
      @stuff.school = @buck.school
      @stuff.matched_at = Time.now
      Donation.transaction do 
        @stuff.save!
        @buck.update_attributes!(:matched_count => Donation.count(:all, :conditions => ["school_id=?", @stuff.school]))
        session[:pc_code] = params[:token]
        session[:pc_user_id] = current_user.id
      end
      flash[:notice] = "密码配对成功，您捐给#{@stuff.school.title}一本书。写两句话给学校和孩子们吧 ;)"
      render :action => "write_comment"
      
    else
      # 密码不正确
      set_message_and_redirect_to_index("密码错误，请重新输入")
    end
    
  end
  
  def comment
    @stuff = Donation.find_by_code(params[:token], :conditions => ["matched_at is not null and user_id=?", current_user] )
    set_message_and_redirect_to_index("密码错误，请重新输入") if @stuff.blank?
    
    unless @stuff.user == current_user
      flash[:notice] = "您不是这张卡的主人，不能写留言"
      redirect_to minisite_postcard_index_url
      return
    end
    

    @stuff.comment = params[:comment]
    @stuff.save!
    
    if params[:join] == "1"
      @group = Group.find(38)
      @group.members << current_user unless @group.joined?(current_user)
    end
    
    flash[:notice] = "谢谢您的支持！"
    redirect_to minisite_postcard_index_url
    

  end
  
  def messages
    @stuffs = Donation.paginate :page => params[:page] || 1, 
                             :conditions => ["comment is not null"], 
                             :order => "matched_at desc",
                             :per_page => 30
  end
  
  def donors
    @school = School.find(params[:id])
    @stuffs = Donation.paginate :page => params[:page] || 1,
                             :conditions => ["school_id = ?", params[:id]],
                             :order => "matched_at desc",
                             :per_page => 30
  end
  
  
  private
  def set_message_and_redirect_to_index(msg = "")
    flash[:postcard_notice] = msg
    redirect_to minisite_postcard_index_url
    return
  end
  
end