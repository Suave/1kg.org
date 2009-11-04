class BulletinsController < ApplicationController
  def index
    @bulletins = Bulletin.find :all, :order => "id desc"
  end
  
  def show
    @bulletin = Bulletin.find params[:id]
    unless @bulletin.redirect_url.blank?
      redirect_to @bulletin.redirect_url
    else
      @comments = @bulletin.comments.available.paginate :page => params[:page] || 1, :per_page => 15
      @comment = BulletinComment.new
    end
    
  end
  
  
end