class Minisite::WeixingfuController < ApplicationController
  def index
    @group = Group.find(:first,:conditions=>{:slug => 'weigongyi'})
    @board = @group.discussion.board
  end
end