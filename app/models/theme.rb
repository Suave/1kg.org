class Theme < ActiveRecord::Base
  include BodyFormat
  
  has_many :topics, :as => 'boardable', :dependent => :destroy
  
  acts_as_paranoid
  acts_as_manageable
  
  before_save :format_content
  
  private
  def format_content
    self.description_html = sanitize(description||'')
  end
end
