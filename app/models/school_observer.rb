class SchoolObserver < ActiveRecord::Observer
  def after_create(school)
    board = Board.new
    board.talkable = SchoolBoard.new(:school_id => school.id)
    board.save!

    #将提交人设为学校大使
    role = Role.create!(:identifier => "roles.school.moderator.#{school.id}")
    school.user.roles << role
    
    # 邮件通知管理员有新学校提交
    Mailer.deliver_submitted_school_notification(school) if school.user
  end
  
  def after_destroy(school)
    Mailer.deliver_destroyed_school_notification(school) if school.user
    Role.find(:all,:conditions => {:identifier => "roles.school.moderator.#{school.id}"}).each {|r| r.delete}
  end
  
  def before_save(school)
    Mailer.deliver_invalid_school_notification(school) if school.user && school.validated_changed? && !school.validated
  end
end
  