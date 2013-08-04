# -*- encoding : utf-8 -*-
class SchoolObserver < ActiveRecord::Observer
  def after_create(school)
    Management.new(:user_id => school.user_id,:manageable_id => school.id,:manageable_type => 'School').save
    Mailer.deliver_submitted_school_notification(school) if school.user
  end
  
  def after_destroy(school)
    Mailer.deliver_destroyed_school_notification(school) if school.user
  end
  
  def before_save(school)
    Mailer.deliver_invalid_school_notification(school) if school.user && school.validated_changed? && !school.validated
  end
end
  
