# -*- encoding : utf-8 -*-
# == Schema Information
# Schema version: 20090430155946
#
# Table name: message_copies
#
#  id           :integer(4)      not null, primary key
#  recipient_id :integer(4)      not null
#  message_id   :integer(4)      not null
#  unread       :boolean(1)      default(TRUE)
#

class MessageCopy < ActiveRecord::Base
	belongs_to 	:message
	belongs_to 	:recipient, :class_name => "User"
	delegate :author, :created_at, :subject, :html_content, :content, :recipients, :to => :message
end
