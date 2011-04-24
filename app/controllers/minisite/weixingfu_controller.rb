class Minisite::WeixingfuController < ApplicationController
  def index
    @group = Group.find(:first,:conditions=>{:slug => 'weixingfu'})
    @board = @group.discussion.board
  end
end