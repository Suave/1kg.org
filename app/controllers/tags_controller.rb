class TagsController < ApplicationController
  def show
    @tag = params[:tag]
    @school_needs = SchoolNeed.find_tagged_with(params[:tag])
    # 需要优化
    @schools = @school_needs.map(&:school).paginate(:per_page => 10, :page => params[:school_page])
    @guides = SchoolGuide.find_tagged_with(params[:tag]).paginate(:per_page => 10, :page => params[:guide_page])
  end
end
