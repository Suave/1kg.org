class StuffBuck < ActiveRecord::Base
  belongs_to :type, :class_name => "StuffType", :foreign_key => "type_id"
  belongs_to :school
  has_many :stuffs, :foreign_key => "buck_id"
  
  validates_presence_of :type_id, :school_id, :quantity
  
  after_create :generate_stuffs
  
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