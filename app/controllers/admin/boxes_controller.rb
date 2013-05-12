# -*- encoding : utf-8 -*-
class Admin::BoxesController < Admin::BaseController
  
  def index 
    @boxs = Box.all
  end
  
  def new 
    @box = Box.new
  end
  
  def create 
    @box = Box.new(params[:box])
    @box.user = current_user 
    @box.save
    redirect_to admin_boxes_path
  end
  
  def edit 
    @box = Box.find(params[:id])
  end
  
  def update 
    @box = Box.find(params[:id])
    @box.update_attributes(params[:box])
    @box.save
    redirect_to admin_boxes_path
  end
  
  def destroy
    @box = Box.find(params[:id])
    @box.destroy
    redirect_to admin_boxes_path
  end
 
end
