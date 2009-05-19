# == Schema Information
# Schema version: 20090430155946
#
# Table name: activity_boards
#
#  id               :integer(4)      not null, primary key
#  activity_id      :integer(4)      not null
#  description      :text
#  description_html :text
#

class ActivityBoard < ActiveRecord::Base
  include BodyFormat
  
  has_one :board, :as => :talkable
  belongs_to :activity
  
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
