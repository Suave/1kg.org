class TagsController < ApplicationController
  def index
    respond_to do |format|
      if params[:tag]
        format.html {redirect_to tag_path(:tag => params[:tag])}
      else
        @tags = SchoolNeed.tag_counts + SchoolGuide.tag_counts
        format.html
      end
    end
  end
  
  def show
    @tag = params[:tag]
    @school_needs = SchoolNeed.find_tagged_with(params[:tag])
    # 需要优化
    @schools = @school_needs.map(&:school).paginate(:per_page => 10, :page => params[:school_page])
    @guides = SchoolGuide.find_tagged_with(params[:tag]).paginate(:per_page => 10, :page => params[:guide_page])
  end
end
