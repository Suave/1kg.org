class School < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :geo
  belongs_to :county
  has_one    :basic,   :class_name => "SchoolBasic"
  has_one    :traffic, :class_name => "SchoolTraffic"
  has_one    :need,    :class_name => "SchoolNeed"
  has_one    :contact, :class_name => "SchoolContact"
  has_one    :local,   :class_name => "SchoolLocal"
  has_one    :finder,  :class_name => "SchoolFinder"
  
  has_one    :discussion, :class_name => "SchoolBoard"
  
  has_many :visited, :dependent => :destroy
  has_many :visitors, :through => :visited, :source => :user, :conditions => "status = #{Visited.status('visited')}"
  has_many :interestings, :through => :visited, :source => :user, :conditions => "status = #{Visited.status('interesting')}"
  has_many :shares
  has_many :photos
  
  named_scope :validated, :conditions => ["validated=? and deleted_at is null and meta=?", true, false], :order => "created_at desc"
  named_scope :available, :conditions => ["deleted_at is null"]
  
  
  
  named_scope :at, lambda { |city|
    geo_id = ((city.class == Geo) ? city.id : city)
    {:conditions => ["(geo_id=?)", geo_id]}
  }
  
  named_scope :locate, lambda { |city_ids|
    {:conditions => ["geo_id in (?)", city_ids]}
  }
  
  @@city_neighbors = {
                        :beijing => {:id => 1, :neighbors => {:hebei => 3, :neimenggu => 27}},
                        :tianjin => {:id => 2, :neighbors => {:hebei => 3, :neimenggu => 27}},
                        :shanghai => {:id =>79, :neighbors => {:zhejiang => 94, :anhui => 106, :jiangxi => 134}},
                        :chongqing => {:id => 273, :neighbors => {:sichuan => 274}},
                        :hongkong => {:id => 391, :neighbors => {:guangdong => 216}},
                        :macao => {:id => 392, :neighbors => {:guangdong => 216, :fujian => 124}}
  }
  
  def after_create
    Mailer.deliver_submitted_school_notification(self)
  end
  
  validates_presence_of :title
  
  
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
      validated.available.locate(ids)
  end
  
  
  def self.recent_upload
    validated.find(:all, :order => "created_at desc", :limit => 10)
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
  
  def school_basic=(basic_attributes)
    if basic_attributes[:id].blank?
      build_basic(basic_attributes)
    else
      basic.attributes = basic_attributes
    end
  end
  
  def school_traffic=(traffic_attributes)
    if traffic_attributes[:id].blank?
      build_traffic(traffic_attributes)
    else
      traffic.attributes = traffic_attributes
    end
  end
 
  def school_need=(need_attributes)
    if need_attributes[:id].blank?
      build_need(need_attributes)
    else
      need.attributes = need_attributes
    end
  end
  
  def school_contact=(contact_attributes)
    if contact_attributes[:id].blank?
      build_contact(contact_attributes)
    else
      contact.attributes = contact_attributes
    end
  end
  
  def school_local=(local_attributes)
    if local_attributes[:id].blank?
      build_local(local_attributes)
    else
      local.attributes = local_attributes
    end
  end
  
  def school_finder=(finder_attributes)
    if finder_attributes[:id].blank?
      build_finder(finder_attributes)
    else
      finder.attributes = finder_attributes
    end
  end
  
  def self.archives(valid = true)
    date_func = "extract(year from created_at) as year,extract(month from created_at) as month"
    
    counts = School.find_by_sql(["select count(*) as count, #{date_func} from schools where validated = ? and deleted_at is null and created_at < ? group by year,month order by year asc,month asc limit ? ", valid, Time.now,count.to_i])
    
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
  
  def self.show_date(year, month, day, valid)
    self.find(:all, 
              :order      => "schools.updated_at desc",
              :conditions => ["created_at LIKE ? and validated = ? and deleted_at is null ", "#{year}-#{month}-#{day}%", valid])
  end
  
end