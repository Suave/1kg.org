class SchoolLocal < ActiveRecord::Base
  include BodyFormat
  
  belongs_to :school
  
  before_save :format_content
  
  private
  def format_content
    advice.strip! if advice.respond_to?(:strip!)
    self.advice_html = advice.blank? ? '' : formatting_body_html(advice)
  end
end