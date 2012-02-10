class Execution < ActiveRecord::Base
  attr_accessor :agree_feedback_terms,:year,:month
  
  belongs_to :project
  belongs_to :school
  belongs_to :user
  belongs_to :village

  acts_as_manageable

  has_many :comments, :as => 'commentable', :dependent => :destroy
  has_many :photos, :as => 'photoable', :order => "id desc", :dependent => :destroy
  has_many :topics, :as => 'boardable', :order => "sticky desc,id desc", :dependent => :destroy
  has_many :bringings
  accepts_nested_attributes_for :bringings 
  has_and_belongs_to_many :boxes, :class_name => 'Bringing'
  
  validates_presence_of :reason,:message => "必须填写申请理由"
  validates_presence_of :plan,:message => "必须填写实施计划"
  validates_presence_of :telephone,:message => "请留下您的电话或手机号码"

  scope :state_is, lambda { |state| {:conditions => {:state => state} }}
  scope :with_box,  :conditions => ["bringings_count > ?",0],:include => [:bringings],:order => 'created_at desc'
  scope :validated_with_box,  :conditions => ["bringings_count > ? and state in (?)",0,['validated','going','finished']],:include => [:bringings],:order => 'created_at desc'
  scope :validated, :conditions => ["state in (?)",["validated","going","finished"]]
  
  def name
    "#{self.community.title}的项目申请"
  end

  def state_tag
    {"validated"=> '已经通过!',"going"=>"已经通过!","finished"=>"已经完成",'waiting' => '在等待审核'}[state]
  end

  def path_tag
    self.bringings_count.zero? ? "/projects/#{self.project_id}/executions/#{self.id}" : "/boxes/execution/#{self.id}"
  end

  def with_box?
    !bringings_count.zero?
  end
  def validate
    #至少要关联一所学校或一所村庄
    if school_id.nil? && village.nil?
      errors.add(:village_id,"必须选择一所村庄")
      errors.add(:school_id,"必须选择一所学校")
    end
  end
  
  def community
    self.school ? self.school : self.village
  end
    
  def last_updated_at
    [self.created_at,self.last_modified_at,(self.topics.empty? ? nil : self.topics.last.created_at),(self.photos.empty? ? nil : self.photos.last.created_at)].compact.max
  end
  
  def validated?
    ["validated","going","finished"].include?(state)
  end

  def refused?
    state == "refused"
  end
  
  state_machine :state, :initial => :waiting do
  
    event :allow  do  
      transition [:refused,:waiting] => :validated
    end
    
    event :refuse do  
      transition [:waiting,:validated,:going] => :refused
    end
    
    event :start do  
      transition :validated => :going
    end  
        
    event :finish do  
      transition [:validated,:going] => :finished
    end
  end
  
end
