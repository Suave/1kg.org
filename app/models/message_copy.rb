# == Schema Information
# Schema version: 20090430155946
#
# Table name: message_copies
#
#  id           :integer         not null, primary key
#  recipient_id :integer         not null
#  message_id   :integer         not null
#  unread       :boolean         default(TRUE)
#

class MessageCopy < ActiveRecord::Base
	belongs_to 	:message
	belongs_to 	:recipient, :class_name => "User"
	delegate :author, :created_at, :subject, :html_content, :content, :recipients, :to => :message
end
