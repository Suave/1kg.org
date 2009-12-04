# == Schema Information
#
# Table name: messages
#
#  id           :integer(4)      not null, primary key
#  author_id    :integer(4)      not null
#  subject      :string(255)
#  content      :text
#  html_content :text
#  deleted      :boolean(1)
#  created_at   :datetime
#  updated_at   :datetime
#

class Message < ActiveRecord::Base
  include BodyFormat
  
	belongs_to :author, :class_name => "User"
	has_many :message_copies
	#A message may have many recipients, which can be found
	#through the copies. Since each copy belongs to a simple
	#recipient
	has_many :recipients, :through => :message_copies
	
	before_create :format_content, :prepare_copies

	attr_accessor :to
	attr_accessible :subject, :content, :to

  validates_presence_of :subject, :message => "请填写标题"
  validates_presence_of :content, :message => "请填写正文"

  named_scope :undeleted, :conditions => {:deleted => false}

  def self.create_system_notification(recipients, title, msg)
    create!(:author_id => 0, :to => recipients, :title => title, :content => msg)
  end

	private

	def prepare_copies
		return if to.blank?

		to.each do |recipient|
			recipient = User.find(recipient)
			message_copies.build(:recipient_id => recipient.id, :unread => true) 
		end
	end

	def format_content
	  content.strip! if content.respond_to?(:strip!)
    self.html_content = content.blank? ? '' : formatting_body_html(content)
#		self.content = auto_link(self.content) { |text| truncate(text, 50) }
#		self.html_content = white_list(self.content)
	end
end
