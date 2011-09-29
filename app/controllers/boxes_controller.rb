class BoxesController < ApplicationController
 
  def index
    @boxes = Box.available
  end

  def design
  end

  def apply
  end

  def new 
    @box = Box.new
  end
  
  def create 
    @box = Box.new(params[:box])
    @box.save
  end
  
  def edit 
    @box = Box.find(params[:id])
  end
  
  def update 
    @box = Box.find(params[:id])
    @box = Box.update_attributes(params[:box])
    @box.save
  end
  
  def destroy
  end
end
