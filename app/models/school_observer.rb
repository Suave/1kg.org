class SchoolObserver < ActiveRecord::Observer
  def after_create(school)
    School.manangements.build(:user_id => schools.user_id).save
    # 邮件通知管理员有新学校提交
    Mailer.deliver_submitted_school_notification(school) if school.user
  end
  
  def after_destroy(school)
    Mailer.deliver_destroyed_school_notification(school) if school.user
  end
  
  def before_save(school)
    Mailer.deliver_invalid_school_notification(school) if school.user && school.validated_changed? && !school.validated
  end
end
  