# == Schema Information
# Schema version: 20090430155946
#
# Table name: stuff_bucks
#
#  id            :integer(4)      not null, primary key
#  type_id       :integer(4)      not null
#  school_id     :integer(4)      not null
#  quantity      :integer(4)      not null
#  matched_count :integer(4)      default(0)
#  created_at    :datetime
#  status        :string(255)
#  notes_html    :text
#

class StuffBuck < ActiveRecord::Base
  belongs_to :type, :class_name => "StuffType", :foreign_key => "type_id"
  belongs_to :school
  has_many :stuffs, :foreign_key => "buck_id"
  
  validates_presence_of :type_id, :school_id, :quantity
  
  after_create :generate_stuffs
  
  def matched_percent
    (matched_count.to_f*100/quantity).to_i
  end
  
  def matched_percent_str
    matched_percent.to_s + "%"
  end
  
  private
  def generate_stuffs
    count = 0
    while count < self.quantity
      code = UUID.create_random.to_s.gsub("-", "").unpack('axaxaxaxaxaxaxax').join('')
      if exist_stuff = Stuff.find_by_code(code)
        next
      else
        stuff = Stuff.new(:code => code)
        stuff.buck = self
        stuff.type = self.type
        stuff.save!
        count += 1
      end
    end
  end
  
end
