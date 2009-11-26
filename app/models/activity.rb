# == Schema Information
# Schema version: 20090430155946
#
# Table name: activities
#
#  id               :integer(4)      not null, primary key
#  user_id          :integer(4)      not null
#  school_id        :integer(4)
#  done             :boolean(1)
#  created_at       :datetime
#  updated_at       :datetime
#  deleted_at       :datetime
#  ref              :string(255)
#  category         :integer(4)      not null
#  title            :string(255)     not null
#  location         :string(255)     not null
#  departure_id     :integer(4)      not null
#  arrival_id       :integer(4)      not null
#  start_at         :datetime
#  end_at           :datetime
#  register_over_at :datetime
#  expense_per_head :string(255)
#  expect_strength  :string(255)
#  description      :text
#  description_html :text
#  comments_count   :integer(4)      default(0)
#  old_id           :integer(4)
#  sticky           :boolean(1)
#

class Activity < ActiveRecord::Base
  include BodyFormat
  
  belongs_to :user
  belongs_to :departure, :class_name => "Geo", :foreign_key => "departure_id"
  belongs_to :arrival, :class_name => "Geo", :foreign_key => "arrival_id"
  
# has_one    :discussion, :class_name => "ActivityBoard"
  
  has_many :participation, :dependent => :destroy
  has_many :participators,  :through => :participation, :source => :user
  
  has_many :comments, :as => 'commentable', :dependent => :destroy
  has_many :shares
#  belongs_to :school

  #named_scope :hiring,   :conditions => ["start_at > ?", Time.now]
  named_scope :available, :conditions => "deleted_at is null" #, :order => "sticky desc, start_at desc, created_at desc"
  named_scope :ongoing,  :conditions => ["end_at > ?", Time.now - 1.day]
  named_scope :over,     :conditions => ["done=? or end_at < ?", true, Time.now - 1.day]
  
  named_scope :in_the_city, lambda { |city|
    geo_id = (city.class == Geo) ? city.id : city
    {:conditions => ["arrival_id = ? and departure_id = ?", geo_id, geo_id] }
  }
  
  named_scope :from_the_city, lambda { |city| 
    geo_id = (city.class == Geo) ? city.id : city
    {:conditions => ["departure_id = ? and arrival_id <> ?", geo_id, geo_id]}
  }
  
  named_scope :on_the_fly, lambda { |city|
    {:conditions => ["departure_id = 0 and arrival_id = 0"]}
  }
  
  named_scope :at, lambda { |city|
    geo_id = (city.class == Geo) ? city.id : city
    {:conditions => ["(departure_id=? or arrival_id=? or departure_id=0 or arrival_id=0)", geo_id, geo_id]}
  }
  
  named_scope :by_category, lambda { |category| 
    {:conditions => ["category=?", category]}
  }

  validates_presence_of :title, :message => "活动名称是必填项"
  validates_presence_of :departure_id, :message => "出发地是必选项"
  validates_presence_of :arrival_id, :message => "目的地是必选项"
  validates_presence_of :start_at, :message => "开始时间是必填项"
  validates_presence_of :end_at, :message => "结束时间是必填项"
  
  
  #before_save :format_content
  
  
  def self.categories
    %w(公益旅游 物资募捐 支教 其他 同城活动 网上活动)
  end
  
  def self.recent_by_category(category)
    available.ongoing.by_category(categories.index(category)).find :all, :order => "created_at desc, start_at desc", :limit => 10
  end
  
  
  def category_name
    self.class.categories[category]
  end
  
  def edited_by(user)
    #user.class == User && (self.user_id == user.id || user.admin?)
    return false unless user.class == User
    return true if self.user_id == user.id
    return true if user.admin?  
    return true if self.departure && User.moderators_of(self.departure).include?(user)
    
  end
  
  def sticky_by?(user)
    return false unless user.class == User
    return true if user.admin?
    return true if self.departure &&  self.departure.city_board.board.has_moderator?(user)
  end
  
  def joined?(user)
    user.class == User && participators.include?(user)
  end
  
  def join_closed?
    (register_over_at && register_over_at < Time.now - 1.day) || done? || (end_at < Time.now - 1.day)
  end
  
  
  def self.archives
    date_func = "extract(year from created_at) as year,extract(month from created_at) as month"
    
    counts = Activity.find_by_sql(["select count(*) as count, #{date_func} from activities where created_at < ? group by year,month order by year asc,month asc",Time.now])
    
    sum = 0
    result = counts.map do |entry|
      sum += entry.count.to_i
      {
        :name => entry.year + "年" + entry.month + "月",
        :month => entry.month.to_i,
        :year => entry.year.to_i,
        :delta => entry.count,
        :sum => sum
      }
    end
    return result.reverse
  end
  
  private
  def format_content
    description.strip! if description.respond_to?(:strip!)
    self.description_html = description.blank? ? '' : formatting_body_html(description)
  end
  
end
