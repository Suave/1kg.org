class Activity < ActiveRecord::Base
  include BodyFormat
  
  belongs_to :user
  belongs_to :departure, :class_name => "Geo", :foreign_key => "departure_id"
  belongs_to :arrival, :class_name => "Geo", :foreign_key => "arrival_id"
#  belongs_to :school

  before_save :format_content
  
  
  def self.categories
    %w(公益旅游 物资募捐 支教 其他)
  end
  
  
  private
  def format_content
    description.strip! if description.respond_to?(:strip!)
    self.description_html = description.blank? ? '' : formatting_body_html(description)
  end
end