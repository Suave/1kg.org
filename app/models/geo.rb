class Geo < ActiveRecord::Base
  include BodyFormat
  acts_as_nested_set
  
  has_many :users
  
  before_save :format_content
  
  private
  def format_content
    description.strip! if description.respond_to?(:strip!)
    self.description_html = description.blank? ? '' : formatting_body_html(description)
  end
  
end