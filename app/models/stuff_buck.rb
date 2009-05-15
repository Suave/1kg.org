# == Schema Information
# Schema version: 20090430155946
#
# Table name: stuff_bucks
#
#  id            :integer         not null, primary key
#  type_id       :integer         not null
#  school_id     :integer         not null
#  quantity      :integer         not null
#  matched_count :integer         default(0)
#  created_at    :datetime
#  status        :string(255)
#  notes_html    :text
#

class StuffBuck < ActiveRecord::Base
  belongs_to :type, :class_name => "StuffType", :foreign_key => "type_id"
  belongs_to :school
  has_many :stuffs, :foreign_key => "buck_id", :dependent => :destroy
  
  validates_presence_of :type_id, :school_id, :quantity
  
  named_scope :for_public_donations, :conditions => ["for_team = ? and hidden = ?", false, false]
  named_scope :for_team_donations,   :conditions => ["for_team = ? and hidden = ?", true, false]  
  
  
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
