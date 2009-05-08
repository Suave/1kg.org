# == Schema Information
# Schema version: 20090430155946
#
# Table name: school_boards
#
#  id               :integer         not null, primary key
#  school_id        :integer         not null
#  description      :text
#  description_html :text
#

class SchoolBoard < ActiveRecord::Base
  include BodyFormat
  
  has_one :board, :as => :talkable
  belongs_to :school
  
  before_save :format_content
  
  def board_id
    board.id
  end
  
  private
  def format_content
    description.strip! if description.respond_to?(:strip!)
    self.description_html = description.blank? ? '' : formatting_body_html(description)
  end
  
end
