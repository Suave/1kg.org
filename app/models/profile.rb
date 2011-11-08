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
  
  
  belongs_to :user
  before_save :correct_blog_url, :format_content
  
  def douban_url
    self.douban.include?('http') ? self.douban : "http://www.douban.com/people/#{self.douban}"
  end
  
  def kaixin001_url
    self.kaixin001.include?('http') ? self.kaixin001 : "http://www.kaixin001.com/home/?uid=#{self.kaixin001}"
  end
  
  def renren_url
    self.renren.include?('http') ? self.renren : "http://renren.com/profile.do?id=#{self.renren}"
  end
  
  def twitter_url
    self.twitter.include?('http') ? self.twitter : "http://www.twitter.com/#{self.twitter}"
  end
  
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
