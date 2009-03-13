class MessageCopy < ActiveRecord::Base
	belongs_to 	:message
	belongs_to 	:recipient, :class_name => "User"
	delegate :author, :created_at, :subject, :html_content, :content, :recipients, :to => :message
end
