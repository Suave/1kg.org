class SentController < ApplicationController
  before_filter :login_required
  
  def index
		@messages = current_messages.undeleted.paginate :per_page => 10,
		                  :page  		=> params[:page],
				  :order 		=> "created_at DESC"
  end

  def show
    @message = current_messages.find(params[:id])
  end

  def new
    @message = current_messages.build
    @recipient = User.find(params[:user_id])
  end

  def create
    # 站内信发出后, 返回第一个收件人的空间
    @message = current_messages.build(params[:message])
    if @message.save
      flash[:notice] = "消息已发出"
      if params[:back_url]
	redirect_to params[:back_url]
      else
        redirect_to user_url(@message.recipients[0])
      end
    else
      @recipient = User.find(params[:message][:to])
      render :action => "new"
    end
  end

   def by_system
    # 系统站内信
    @message = Message.new(params[:message])
    @message.author_id = 0
    if @message.save
      flash[:notice] = "消息已发出"
      if params[:back_url]
	redirect_to params[:back_url]
      else
        redirect_to user_url(@message.recipients[0])
      end
    else
      @recipient = User.find(params[:message][:to])
      render :action => "new"
    end
  end
  
  def destroy
    @message = current_messages.find(params[:id])
    @message.update_attribute('deleted', true)
    flash[:notice] = "你刚刚删除了一条站内消息"
    redirect_to index_path
  end

  private

  def current_messages
    current_user.sent_messages
  end

  def index_path
    user_sent_index_path(current_user)
  end
end