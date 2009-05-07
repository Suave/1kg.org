# == Schema Information
# Schema version: 20090430155946
#
# Table name: public_boards
#
#  id               :integer         not null, primary key
#  title            :string(100)     default(""), not null
#  description      :text
#  description_html :text
#  position         :integer         default(999), not null
#  slug             :string(255)
#

class PublicBoard < ActiveRecord::Base
  include BodyFormat
  
  has_one :board, :as => :talkable
  
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
