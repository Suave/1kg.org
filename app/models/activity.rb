# -*- encoding : utf-8 -*-
class Activity < ActiveRecord::Base

  belongs_to :user
  belongs_to :school
  belongs_to :departure, :class_name => "Geo", :foreign_key => "departure_id"
  belongs_to :arrival, :class_name => "Geo", :foreign_key => "arrival_id"
  belongs_to :team

  has_many :participations, :dependent => :destroy
  has_many :participators,  :through => :participations, :source => :user
  has_many :comments, :as => 'commentable', :dependent => :destroy
  has_many :topics, :as => 'boardable', :dependent => :destroy
  has_many :photos, :as => 'photoable', :dependent => :destroy
  belongs_to :main_photo, :class_name => 'Photo'

  acts_as_taggable
  acts_as_manageable
  acts_as_ownable
  acts_as_spamable

  has_attached_file :image, :styles => {:'120x120' => ["120x120#"],:'64x64' => ["64x64#"]},
                            :url=>"/media/activities/:id/:attachment/:style.:extension",
                            :default_style=> :'64x64'

  scope :ongoing,  where(["end_at > ?", Time.now - 1.day])
  scope :over,     where(["end_at < ?", Time.now - 1.day])
  scope :by_team,  where(:by_team => true)
  scope :hot,      where(["main_photo_id is not null and created_at > ?",1.months.ago]).limit(4).order("participations_count desc")
  scope :recent,   where(['created_at > ?',1.month.ago])
  scope :by_category, lambda { |category|
    {:conditions => ["category=?", category]}
  }

  validates_presence_of :title, :message => "这是必填项"
  validates_presence_of :departure_id, :message => "这是必选项"
  validates_presence_of :arrival_id, :message => "这是必选项"
  validates_presence_of :start_at, :message => "这是必填项"
  validates_presence_of :end_at, :message => "这是必填项"

  def organizer
    self.by_team ? self.team : self.user
  end

  def main_photo_url(style=nil)
    self.main_photo.blank?  ? "/images/activity_thumb_#{category}.png" : main_photo.image.url(style)
  end

  def name
    "活动：#{title}"
  end

  def validate
    errors.add(:title,"发贴频率过快") if self.user.activities.find(:all,:limit=>2,:conditions => ["created_at > ?",1.minute.ago]).size > 1
    if self.user.activities.size > 0 && (self.user.created_at > 1.day.ago)
      errors.add(:title,"新用户只限每天发一篇活动")
    end
    if /小姐|发票/.match(title)
      errors.add(:title,"敏感词")
    end
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

  before_save :format_content

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

  def category_name
    self.class.categories[category]
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
        :name => "#{entry.year}年#{entry.month}月",
        :month => entry.month.to_i,
        :year => entry.year.to_i,
        :delta => entry.count,
        :sum => sum
      }
    end
    return result.reverse
  end

  def html
    self.clean_html
  end

  def has_spam_word?
    check_spam_word_for(self,'title')
  end

  private
  def format_content
      self.clean_html = sanitize(self.clean_html)
  end
end
