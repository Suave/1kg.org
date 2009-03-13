class Profile < ActiveRecord::Base
  include BodyFormat
  
  belongs_to :user
  
  before_save :correct_blog_url, :format_content
  
  private
  def format_content
    bio.strip! if bio.respond_to?(:strip!)
    self.bio_html = bio.blank? ? '' : formatting_body_html(bio)
  end
  
  def correct_blog_url
    unless self.blog_url.to_s.empty?
      unless self.blog_url =~ /^http\:\/\//
        self.blog_url = "http://#{self.blog_url}"
      end
    end
  end
end