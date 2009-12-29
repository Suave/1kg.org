class MessageCopyObserver < ActiveRecord::Observer
  def after_create(message_copy)
    Mailer.deliver_message_notification(message_copy) if message_copy.recipient.email_notify
  end
end
