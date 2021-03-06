class ReceivedController < ApplicationController
  include Util
  
	before_filter :login_required

  def index
		@copies = current_messages.paginate :per_page => 30,
																				:page 		=> params[:page],
																				:include 	=> [:message],
																				:order 		=> "unread desc, messages.created_at DESC"
  end

  def show
		@copy = current_messages.find(params[:id])
		@prev = current_messages.find(:first, :conditions => ['id > ?', @copy.id], :order => 'id')
		@next = current_messages.find(:first, :conditions => ['id < ?', @copy.id], :order => 'id DESC')
		@copy.toggle!(:unread) if @copy.unread
  end
	
	def reply
		@original_message = current_messages.find(params[:id])
		@recipient = @original_message.author
		subject = @original_message.subject.sub(/^(Re: )?/, "Re: ")
		content = "\r\n\r\n\r\n\r\n#{@original_message.author.login}说：\r\n| #{@original_message.content.gsub("\r\n", "\r\n| ")}"
		@message = current_user.sent_messages.build(:subject => subject, :content => content)
	end

  def create
		@message = current_user.sent_messages.build(params[:message])

		if @message.save
		  flash[:notice] = "消息已发出"
	    redirect_to index_path
    else
      @recipient = User.find(params[:message][:to])
      render :action => "reply"
    end
  end
    
  def destroy
    @copy = current_messages.find(params[:id])
    @copy.destroy
    flash[:notice] = "你刚刚删除了一条站内信"
    redirect_to index_path
  end
  
  def destroy_all
    delete_all MessageCopy, params[:delete]
    redirect_to index_path
  end
  

  private 
  
  def current_messages
    current_user.received_messages
  end

  def index_path
    user_received_index_path(current_user)
  end

end
