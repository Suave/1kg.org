# == Schema Information
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
#  description_html :text
#  comments_count   :integer(4)      default(0)
#  shares_count      :integer(4)      default(0)
#  old_id           :integer(4)
#  sticky           :boolean(1)
#  clean_html       :text
#  main_photo_id            :integer(4)

class Activity < ActiveRecord::Base
  include BodyFormat
  
  belongs_to :user
  belongs_to :school
  belongs_to :departure, :class_name => "Geo", :foreign_key => "departure_id"
  belongs_to :arrival, :class_name => "Geo", :foreign_key => "arrival_id"
  belongs_to :team
  
  has_many :participations, :dependent => :destroy
  has_many :participators,  :through => :participations, :source => :user
  
  has_many :comments, :as => 'commentable', :dependent => :destroy
  has_many :shares,                         :dependent => :destroy

  has_many :photos, :order => "id desc", :dependent => :destroy
  belongs_to :main_photo, :class_name => 'Photo'
  
  acts_as_taggable
  
  named_scope :available, :conditions => "deleted_at is null" #, :order => "sticky desc, start_at desc, created_at desc"
  named_scope :ongoing,  :conditions => ["end_at > ?", Time.now - 1.day]
  named_scope :over,     :conditions => ["end_at < ?", Time.now - 1.day]
  named_scope :by_team, :conditions => {:by_team => true}, :order => "created_at desc"
  
  named_scope :for_the_city, lambda { |city|
    geo_id = (city.class == Geo) ? city.id : city
    {:conditions => ["arrival_id = ? or departure_id = ?", geo_id, geo_id] }
  }
    
  named_scope :at, lambda { |city|
    geo_id = (city.class == Geo) ? city.id : city
    {:conditions => ["(departure_id=? or arrival_id=? or departure_id=0 or arrival_id=0)", geo_id, geo_id]}
  }
  
  named_scope :by_category, lambda { |category| 
    {:conditions => ["category=?", category]}
  }

  validates_presence_of :title, :message => "这是必填项"
  validates_presence_of :departure_id, :message => "这是必选项"
  validates_presence_of :arrival_id, :message => "这是必选项"
  validates_presence_of :start_at, :message => "这是必填项"
  validates_presence_of :end_at, :message => "这是必填项"
  validates_presence_of :description_html, :message => "活动介绍是必填项"
  
  def organizer
    self.by_team ? self.team : self.user
  end
  
  
  def validate
    begin
      if (Activity.find(id).start_at < Time.now) and ((Activity.find(id).start_at != start_at) or (Activity.find(id).end_at != end_at))
        errors.add(:time,"已经不能修改活动时间")
      end
    rescue  
        if start_at && end_at 
          unless  ((Time.now - 1.day)<= start_at)&&(start_at <= end_at)&&(end_at <= start_at + 3.month )
        errors.add(:time,"日期填写不正确　")
        end
      end
    end
    
  end
  
  
  acts_as_paranoid
  
  before_save :format_content
  after_create :create_feed
  
  define_index do
    # fields
    indexes title
    indexes location
    indexes clean_html, :as => :description
    indexes departure.name, :as => :start
    indexes arrival.name, :as => :destination
    indexes user.login, :as => :organizer
    
    has :category
    has :end_at
    has :done, :as => :over
    has :start_at
  end
  
  def self.categories
    %w(公益旅游 物资募捐 支教 其他 同城活动 网上活动)
  end
  
  def self.recent_by_category(category)
    available.ongoing.find :all,:order => "created_at desc", :limit => 8,:conditions => ["category=?",categories.index(category)], :include => [:main_photo,:departure, :arrival]
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
    
    counts = Activity.find_by_sql(["select count(*) as count, #{date_func} from activities where created_at < ? and deleted_at IS NULL group by year,month order by year asc,month asc",Time.now])
    
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
  
  def html
    self.update_attribute(:clean_html, sanitize(self.description_html, true)) if self.clean_html.blank?
    self.clean_html
  end
  
  private
  def format_content
    begin
      self.clean_html = sanitize(self.description_html||'', true)
    rescue
      self.clean_html = self.description_html
    end
  end
  
  def create_feed
    self.school.feed_items.create(:content => %(#{self.user.login} 在#{self.created_at.to_date}为#{self.school.title}发起了一个新活动：#{self.title}), :user_id => self.user.id, :category => 'activity',
                :item_id => self.id, :item_type => 'Activity') if self.school
  end
end
