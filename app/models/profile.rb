# == Schema Information
#
# Table name: profiles
#
#  id         :integer(4)      not null, primary key
#  user_id    :integer(4)
#  blog_url   :string(255)
#  bio        :text
#  bio_html   :text
#  last_name  :string(255)
#  first_name :string(255)
#  gender     :integer(1)
#  birth      :date
#  phone      :string(255)
#  privacy    :integer(1)
#

class Profile < ActiveRecord::Base
  include BodyFormat
  
  belongs_to :user
  
  before_save :correct_blog_url, :format_content
  
  private
  def format_content
    self.bio_html = sanitize(bio||'', true)
  end
  
  def correct_blog_url
    unless self.blog_url.to_s.empty?
      unless self.blog_url =~ /^http\:\/\//
        self.blog_url = "http://#{self.blog_url}"
      end
    end
  end
end
