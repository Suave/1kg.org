require 'uuid'

class Minisite::Postcard::DashboardController < ApplicationController
  before_filter :login_required, :except => [:index, :love_message]
  
  def index
    @board = PublicBoard.find_by_slug("postcard").board
    @topics = @board.topics.find(:all, :order => "sticky desc, last_replied_at desc", :limit => 10)
    
    postcard = StuffType.find_by_slug("postcard")
    @school_bucks = postcard.bucks.find :all, :include => [:school]
    @stuff = postcard.stuffs.find(:first, :conditions => ["matched_at is not null"], :order => "matched_at desc")
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
      @stuff = Stuff.find_by_code(params[:password])
      if @stuff.nil?
        # 密码不正确，没找到对应的stuff
        set_message_and_redirect_to_index "您输入的密码不正确，请检查一下重新输入"
      else
        # 密码正确，找到stuff，进一步判断stuff是否已配对
        if @stuff.matched?
          # 已成功配对
          set_message_and_redirect_to_index "您这张贺卡已经选过学校"
        else
          # 尚未配对
          postcard = StuffType.find_by_slug("postcard")
          @bucks = postcard.bucks.find :all, :include => [:school], :conditions => ["matched_count < quantity"] 
          render :action => "school_list"
        end
      end
    end
  end
  
  def give
    @stuff = Stuff.find_by_code(params[:token])
    set_message_and_redirect_to_index("密码错误，请重新输入") if @stuff.blank?
    
    if @stuff.matched?
      flash[:notice] = "您已选择#{@stuff.school.title}学校，写两句话给学校和孩子们吧 ;)"
    else
      @buck = StuffBuck.find(params[:id])
      @stuff.user = current_user
      @stuff.school = @buck.school
      @stuff.matched_at = Time.now
      Stuff.transaction do 
        @stuff.save!
        @buck.update_attributes!(:matched_count => Stuff.count(:all, :conditions => ["school_id=?", @stuff.school]))
      end
      flash[:notice] = "密码配对成功，您捐给#{@stuff.school.title}一本书。写两句话给学校和孩子们吧 ;)"
    end
    
    render :action => "write_comment"
    
  end
  
  def comment
    @stuff = Stuff.find_by_code(params[:token])
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
  
  private
  def set_message_and_redirect_to_index(msg = "")
    flash[:postcard_notice] = msg
    redirect_to minisite_postcard_index_url
    return
  end
  
  
=begin  
  def code_test
    1000.times do
      logger.info UUID.create_random.to_s.gsub("-", "").unpack('axaxaxaxaxaxaxax').join('')
    end
    render :action => "index"
  end
=end  
end