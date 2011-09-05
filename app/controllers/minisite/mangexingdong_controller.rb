class Minisite::MangexingdongController < ApplicationController
  def index
    @group = Group.find(:first,:conditions=>{:slug => 'mangexingdong'})
    @board = @group.discussion.board
  end
end
