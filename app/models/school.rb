# == Schema Information
# Schema version: 20090430155946
#
# Table name: schools
#
#  id                  :integer(4)      not null, primary key
#  user_id             :integer(4)
#  ref                 :string(255)
#  validated           :boolean(1)
#  meta                :boolean(1)
#  created_at          :datetime
#  updated_at          :datetime
#  deleted_at          :datetime
#  category            :integer(4)
#  geo_id              :integer(4)
#  county_id           :integer(4)
#  title               :string(255)     not null
#  last_modified_at    :datetime
#  last_modified_by_id :integer(4)
#  old_id              :integer(4)
#

class School < ActiveRecord::Base
  belongs_to :user
  belongs_to :geo
  belongs_to :county
  belongs_to :validator, :class_name => "User", :foreign_key => "validated_by_id"

  has_one    :basic,   :class_name => "SchoolBasic", :dependent => :destroy
  has_one    :traffic, :class_name => "SchoolTraffic", :dependent => :destroy   # Should be removed.
  has_many   :guides,  :class_name => "SchoolGuide", :dependent => :destroy, :order => 'updated_at DESC'
  has_one    :need,    :class_name => "SchoolNeed", :dependent => :destroy 
  has_one    :contact, :class_name => "SchoolContact", :dependent => :destroy
  has_one    :local,   :class_name => "SchoolLocal", :dependent => :destroy
  has_one    :finder,  :class_name => "SchoolFinder", :dependent => :destroy
  has_many   :snapshots, :class_name => "SchoolSnapshot", :dependent => :destroy
  
  accepts_nested_attributes_for :basic, :traffic, :need, :contact, :local, :finder
  
  has_one  :discussion, :class_name => "SchoolBoard", :dependent => :destroy
  has_many :shares, :order => "id desc"
  has_many :photos, :order => "id desc"
  belongs_to :main_photo, :class_name => 'Photo'
  has_many :visited, :dependent => :destroy
  has_many :visitors, :through => :visited, 
                      :source => :user, 
                      :conditions => "status = #{Visited.status('visited')}"
                      
  has_many :interestings, :through => :visited, 
                          :source => :user, 
                          :conditions => "status = #{Visited.status('interesting')}"

  delegate :address, :zipcode, :master, :telephone, :level_amount, :teacher_amount, :student_amount, :class_amount, :to => :basic
  
  named_scope :validated, :conditions => ["validated=? and deleted_at is null and meta=?", true, false], :order => "created_at desc"
  named_scope :available, :conditions => ["deleted_at is null"]
  named_scope :not_validated, :conditions => ["deleted_at is null and validated=? and meta=?", false, false], :order => "created_at desc"  
  named_scope :at, lambda { |city|
    geo_id = ((city.class == Geo) ? city.id : city)
    {:conditions => ["(geo_id=?)", geo_id]}
  }
  
  named_scope :locate, lambda { |city_ids|
    {:conditions => ["geo_id in (?)", city_ids]}
  }
  named_scope :top10_popular, :order => 'last_month_average_karma DESC', :limit => 10
  
  @@city_neighbors = {
                        :beijing => {:id => 1, :neighbors => {:hebei => 3, :neimenggu => 27}},
                        :tianjin => {:id => 2, :neighbors => {:hebei => 3, :neimenggu => 27}},
                        :shanghai => {:id =>79, :neighbors => {:zhejiang => 94, :anhui => 106, :jiangxi => 134}},
                        :chongqing => {:id => 273, :neighbors => {:sichuan => 274}},
                        :hongkong => {:id => 391, :neighbors => {:guangdong => 216}},
                        :macao => {:id => 392, :neighbors => {:guangdong => 216, :fujian => 124}}
  }
  
  attr_accessor :city, :city_unit, :town, :town_unit, :village
  
  def after_create
    # remove @ 09.8.24, because of SMTPServer Busy raise exception
    Mailer.deliver_submitted_school_notification(self) if self.user
  end
  
  def before_create
    # 确保用户只提交了学校基本信息也不会出错
    self.traffic ||= SchoolTraffic.new
    self.need ||= SchoolNeed.new
    self.contact ||= SchoolContact.new
    self.finder ||= SchoolFinder.new
    self.local ||= SchoolLocal.new
  end
  
  def before_save
    # TODO: how to skip callbacks?
    if User.current_user
      self.last_modified_at = Time.now
      self.last_modified_by_id = User.current_user.id
    end
    
    # 将学校流行度存入数据库
    snapshot = self.snapshots.find_or_create_by_created_on(Date.today)
    snapshot.karma = karma
    snapshot.save
  end
  
  validates_presence_of :geo_id, :message => "必选项"
  validates_presence_of :title, :message => "必填项"
  
  # 用于导入博客学校
  class << self
    include SchoolImport
  end
  
  def self.categories
    %w(小学 中学 四川灾区板房学校)
  end
  
  def self.get_near_schools_at(geo)
 
      root = geo.root? ? geo : geo.parent
      ids =[root.id]
      if not root.leaf?
        ids += root.children.map(&:id)
      end
      
      @@city_neighbors.each do |k,v|
        if v[:id] == root.id
          v[:neighbors].each do |province, id|
            ids += Geo.find(id).children.map(&:id)
          end
        end
      end
      #logger.info ids
      #logger.info ids.class
      #validated.available.find(:all, :conditions => ["geo_id in (?)", ids])
      validated.locate(ids)
  end
  
  def hit!
    self.class.increment_counter :hits, id
  end

  def last_topic
    self.discussion.board.topics.find(:first, :order => "last_replied_at desc")
  end

  def self.recent_upload
    validated.find(:all, :order => "created_at desc", :limit => 10)
  end
  
  def deleted?
    deleted_at.blank? ? false : true
  end
  
  def has_moderator?(user)
    return false unless user.class == User 
    
    return (
      user.has_role?('roles.admin') ||
      user.has_role?('roles.schools.moderator') ||
      user.has_role?("roles.school.moderator.#{self.id}")
    )
  end

  def validated_by(user)
    return has_moderator?(user) 
  end
  
  def edited_by(user)
    return has_moderator?(user) || user.id == self.user_id
  end
  
  
  def destroyed_by(user)
    return edited_by(user)
  end
  
  def visited?(user)
    return false unless user.class == User
    
    visited = Visited.find(:first, :conditions => ["user_id=? and school_id=?", user.id, self.id])
    if visited.nil?
      false
    elsif visited.status == Visited.status('visited')
      'visited'
    elsif visited.status == Visited.status('interesting')
      'interesting'
    else
      raise "学校访问数据错误"
    end
  end
  
  # 0 => invalidated, 1 => valid, 2 => meta
  def icon_type
    meta ? 2 : (validated ? 1 : 0)
  end

  def self.archives(valid = true)
    date_func = "extract(year from created_at) as year,extract(month from created_at) as month"
    condition_time = valid ? "validated_at" : "created_at"
    counts = School.find_by_sql(["select count(*) as count, #{date_func} from schools where validated = ? and deleted_at is null and #{condition_time} < ? group by year,month order by year asc,month asc limit ? ", valid, Time.now,count.to_i])
    
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
  
  include FusionChart
  # 绘制月活跃度变化图
  def karma_chart
    #由于数据不足，先显示过去7天的活跃度变化
    data = []
    6.downto(0) do |i|
      day = Date.today - i.day
      snapshot = self.snapshots.find_by_created_on(day)
      karma = snapshot.nil? ? rand(10) : snapshot.karma
      data << [day.to_s, karma]
    end
    
    column_2d_chart("过去一周活跃度变化", data, '时间', 'Karma')
  end
  
  class << self
    include FusionChart
    def most_popular_chart
      @schools = School.top10_popular
      data = []
      @schools.each do |school|
        data << ["#{school.title}", school.last_month_average_karma]
      end
    
      column_2d_chart("最活跃学校", data, '活跃度', 'School')
    end
  end
  
  def self.show_date(year, month, day, valid)
    if valid
      # 已验证学校，以验证时间为准
      self.available.find(:all, 
                          :order      => "schools.updated_at desc",
                          :conditions => ["validated_at LIKE ? and validated = ?", "#{year}-#{month}-#{day}%", true])
    else
      # 待验证学校，以提交时间为准
      self.available.find(:all,
                          :order => "schools.validated_at desc",
                          :conditions => ["created_at like ? and validated = ?", "#{year}-#{month}-#{day}%", false] )
    end
  end
end
