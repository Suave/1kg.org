class Admin::GoodPhotosController < Admin::BaseController
  before_filter :find_good
  
  def index
    @photos = @good.photos
  end
  
  def new
    @photo = GoodPhoto.new(:good_id => @good.id)
  end
  
  def create
    @photo = @good.photos.build(params[:photo])
    if @photo.save
      flash[:notice] = "图片上传成功"
      redirect_to admin_good_photos_url(@good)
    else
      render :action => "new"
    end
  end
  
  
  private
  def find_good
    @good = Good.find params[:good_id]
  end
  
end