class BulletinsController < ApplicationController
  def index
    @bulletins = Bulletin.find :all, :order => "id desc"
  end
  
  def show
    @bulletin = Bulletin.find params[:id]
  end
  
  
end