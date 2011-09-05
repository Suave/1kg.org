class Minisite::MangexingdongController < ApplicationController
  def index
    @group = Group.find(:first,:conditions=>{:slug => 'weixingfu'})
    @board = @group.discussion.board
  end
end
