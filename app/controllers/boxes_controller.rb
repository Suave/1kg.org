class BoxesController < ApplicationController
 
  before_filter :login_required, :only => [:create,:update,:new,:edit,:apply]

  def index
    @boxes = Box.available
  end

  def design
    @boxes = Box.available
    @designs = Box.published
  end

  def use
  end

  def apply
    @execution = Execution.new
    @boxes = Box.available
    @bringings = @execution.bringings.build
    @schools = (current_user.followed_schools + current_user.envoy_schools + current_user.visited_schools).uniq
  end

  def new 
    @box = Box.new
  end
  
  def create
    @box = Box.new(params[:box])
    @box.user = current_user
    @box.save
    flash[:notice] = "谢谢! 你的设计已经提交，我们会尽快确认 :)"
    redirect_to design_boxes_path
  end
  
  def edit 
    @box = Box.find(params[:id])
  end
  
  def update 
    @box = Box.find(params[:id])
    @box = Box.update_attributes(params[:box])
    @box.save
    redirect_to box_path(box)
  end
  
end
