# -*- encoding : utf-8 -*-
class Theme < ActiveRecord::Base
  
  
  has_many :topics, :as => 'boardable', :dependent => :destroy
  
  
  acts_as_manageable
  
  before_save :format_content
  
  private
  def format_content
    self.description_html = sanitize(description||'')
  end
end
