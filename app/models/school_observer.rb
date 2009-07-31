class SchoolObserver < ActiveRecord::Observer
  def after_create(school)
    board = Board.new
    board.talkable = SchoolBoard.new(:school_id => school.id)
    board.save!
    
    role = Role.create!(:identifier => "roles.school.moderator.#{school.id}")
    
    #将提交人设为爱心大使
    school.user.roles << role
    
    # 检查学校所在城市是否有同城，如果没有则创建
=begin
    city_board = CityBoard.find(:first, :conditions => ["geo_id=?", school.geo_id])
    if city_board.nil?
      board = Board.new
      board.talkable = CityBoard.new(:geo_id => school.geo_id)
      board.save!
    end
=end
  end
end
  