# == Schema Information
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
#  for_team_tip  :text
#  for_team      :boolean(1)
#  hidden        :boolean(1)
#

# Requirement 对应学校大使为某一个学校申请的物资需求，如200本书，300跟铅笔等等

class Requirement < ActiveRecord::Base
  set_table_name "stuff_bucks"
  
  attr_accessor :agree_feedback_terms
  
  belongs_to :requirement_type, :foreign_key => "type_id", :counter_cache => "requirements_count"
  belongs_to :school
  belongs_to :applicator, :class_name => "User", :foreign_key => "applicator_id"
  has_many :donations, :foreign_key => "buck_id", :dependent => :destroy
  
  validates_presence_of :type_id, :school_id,:message => "必须选择一所学校"
  validates_presence_of :apply_reason,:message => "必须填写申请理由"
  validates_presence_of :apply_plan,:message => "必须填写实施计划"
  validates_presence_of :applicator_telephone,:message => "请留下您的电话或手机号码"
  validates_numericality_of :quantity,:message => "必须填写申请数量"
  validates_acceptance_of :agree_feedback_terms,:message => "只有承诺反馈要求，才能申请项目"
  
  
  
  
  named_scope :confirmed, :conditions => ["validated = ?", true]
  named_scope :unconfirmed, :conditions => ["validated = ? or validated IS NULL", false]
  named_scope :for_public_donations, :conditions => ["for_team = ? and hidden = ?", false, false]
  named_scope :for_team_donations,   :conditions => ["for_team = ? and hidden = ?", true, false]  
  
  #after_create :generate_stuffs
  
  def matched_percent
    (matched_count.to_f*100/quantity).to_i
  end
  
  def matched_percent_str
    matched_percent.to_s + "%"
  end
=begin  
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
=end
end
