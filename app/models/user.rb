# == Schema Information
#
# Table name: users
#
#  id                        :integer(4)      not null, primary key
#  login                     :string(255)
#  email                     :string(255)
#  crypted_password          :string(40)
#  salt                      :string(40)
#  created_at                :datetime
#  updated_at                :datetime
#  remember_token            :string(255)
#  remember_token_expires_at :datetime
#  activation_code           :string(40)
#  activated_at              :datetime
#  state                     :string(255)     default("passive")
#  deleted_at                :datetime
#  avatar                    :string(255)
#  geo_id                    :integer(4)
#  guides_count              :integer(4)
#  topics_count              :integer(4)
#  shares_count              :integer(4)
#  posts_count               :integer(4)
#  ip                        :string(255)
#  email_notify              :boolean(1)      default(TRUE)
#

require 'digest/sha1'
class User < ActiveRecord::Base
  acts_as_user
  # Virtual attribute for the unencrypted password
  attr_accessor :password
  cattr_accessor :current_user

  acts_as_paranoid
  
  validates_presence_of     :login, :message => "用户名不能为空"
  validates_presence_of     :email, :message => "邮件地址不能为空"
  validates_presence_of     :password,                   :if => :password_required?, :message => "密码不能为空"
  validates_presence_of     :password_confirmation,      :if => :password_required?, :message => "确认密码不能为空"
  validates_length_of       :password, :within => 4..40, :if => :password_required?, :message => "密码长度在4-40个字符之间"
  validates_confirmation_of :password,                   :if => :password_required?, :message => "两次输入的密码不一致"
  validates_length_of       :login,    :within => 2..40, :message => "用户名长度在2-40个字符之间"
  validates_length_of       :email,    :within => 3..100, :message => "邮件地址长度在3-100个字符之间"
  validates_uniqueness_of   :email, :case_sensitive => false, :message => "邮件地址已被占用"
  validates_format_of       :email,    :with => /\A[\w\.%\+\-]+@(?:[A-Z0-9\-]+\.)+(?:[A-Z]{2}|com|org|net|edu|gov|mil|biz|info|mobi|name|aero|jobs|museum)\z/i, :message => "邮件地址格式不正确"
  
  file_column :avatar, :magick => {
                              :geometry => "72x72>",
                              :versions => {"small" => "16x16", "medium" => "32x32", "large" => "48x48"}
                            }
  
  belongs_to :geo
  
  has_and_belongs_to_many :roles, :uniq => true

  define_index do
    # fields
    indexes login
    indexes email
    indexes profile.bio, :as => :bio
  end
  
  # This method returns true if the user is assigned the role with one of the
  # role titles given as parameters. False otherwise.
  def has_role?(*roles_identifiers)
      roles.any? { |role| roles_identifiers.include?(role.identifier) }
  end

  has_one :profile, :dependent => :destroy 
  
  
  has_many :comments, :dependent => :destroy 
  has_many :submitted_activities, :class_name => "Activity", 
                                  :conditions => "deleted_at is null", 
                                  :order => "created_at desc", 
                                  :dependent => :destroy
  has_many :participations, :dependent => :destroy
  has_many :participated_activities, :through => :participations, 
                                     :source => :activity,
                                     :order => "participations.created_at desc"
  
  has_many :submitted_schools, :class_name => "School", 
                               :conditions => "deleted_at is null",
                               :order => "created_at desc", 
                               :dependent => :destroy
  has_many :visiteds, :dependent => :destroy 
  has_many :visited_schools, :through => :visiteds, 
                             :source => :school,
                             :order => "visiteds.created_at desc"
  
  has_many :topics, :order => "topics.created_at desc", :dependent => :destroy 
  has_many :posts, :order => "posts.created_at desc", :dependent => :destroy 
  has_many :shares, :order => "created_at desc", :dependent => :destroy
  has_many :photos, :order => "created_at desc", :dependent => :destroy 
  
  #add relationship between messages			
  has_many :sent_messages, 			:class_name => "Message", 
											  :foreign_key => "author_id", :dependent => :destroy 
	has_many :received_messages, 	:class_name => "MessageCopy", 
															 	:foreign_key => "recipient_id", :dependent => :destroy 
	has_many :unread_messages, 		:class_name 		=> "MessageCopy",
														 		:conditions 		=> {:unread => true},
														 		:foreign_key 	=> "recipient_id", :dependent => :destroy 
	has_many :neighborhoods, :dependent => :destroy, :dependent => :destroy 
	has_many :neighbors, :through => :neighborhoods,
	                     :order => "neighborhoods.created_at desc"
  
  has_many :memberships, :dependent => :destroy
  has_many :leaderships, :dependent => :destroy
  has_many :joined_groups, :through => :memberships, 
                           :source => :group,
                           :order => "memberships.created_at desc"
  
  has_many :donations, :dependent => :destroy
  has_many :votes, :dependent => :destroy
  has_many :activities, :dependent => :destroy
  has_many :photos, :dependent => :destroy
  has_many :games, :dependent => :destroy
  has_many :activities, :dependent => :destroy
  has_many :co_donations, :dependent => :destroy
  has_many :sub_donations, :dependent => :destroy
  
  has_many :followings, :foreign_key => 'follower_id'
  has_many :feed_items, :as => 'owner'
  
  before_save :encrypt_password
  
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :password, :password_confirmation, :avatar

  acts_as_state_machine :initial => :pending, :column => :state
  state :passive
  state :pending, :enter => :make_activation_code
  state :active,  :enter => :do_activate
  state :suspended
  state :deleted, :enter => :do_delete

  event :register do
    transitions :from => :passive, :to => :pending, :guard => Proc.new {|u| !(u.crypted_password.blank? && u.password.blank?) }
  end
  
  event :activate do
    transitions :from => :pending, :to => :active 
  end
  
  event :suspend do
    transitions :from => [:passive, :pending, :active], :to => :suspended
  end
  
  event :delete do
    transitions :from => [:passive, :pending, :active, :suspended], :to => :deleted
  end

  event :unsuspend do
    transitions :from => :suspended, :to => :active,  :guard => Proc.new {|u| !u.activated_at.blank? }
    transitions :from => :suspended, :to => :pending, :guard => Proc.new {|u| !u.activation_code.blank? }
    transitions :from => :suspended, :to => :passive
  end

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(email, password)
    u = find_in_state :first, :active, :conditions => {:email => email} # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    remember_me_for 2.weeks
  end

  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end

  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end

  # Returns true if the user has just been activated.
  def recently_activated?
    @activated
  end
  
  def admin?
    has_role?("roles.admin")
  end
  
  def envoy?
    !self.roles.find(:first, :conditions => ["identifier LIKE ?", "roles.school.moderator.%"]).blank?
  end
  
  def has_neighbor?(user)
    user.neighbors.include?(self)
  end
  
  def neighbor_addable_by?(user)
    (user != nil) and (id != user.id) and not has_neighbor?(user)
  end
  
  def neighbor_removeable_by?(user)
    (user != nil) and (id != user.id) and has_neighbor?(user)
  end
  
  def school_moderator?
    !self.roles.find_by_identifier("roles.schools.moderator").nil?
  end

  def envoy_schools(number = nil)
     #self.roles.map {|r|  School.find(:first, :conditions => {:validated => true, :deleted_at => nil,:id => (r.identifier).split('.').last.to_i }) if r.identifier =~ /^roles.school.moderator./}.compact
    a = self.roles.map{|r|((r.identifier).split('.').last.to_i ) if r.identifier =~ /^roles.school.moderator./}.compact
    if number
      a = School.validated.find(:all,:conditions => ["id in (?)",a[0,number]])
    else
      a = School.validated.find(:all,:conditions => ["id in (?)",a])
    end  
  end
  
  
  def self.recent_citizens
    find(:all, :conditions => ["state='active'"],
               :order => "id desc",
               :limit => 9)
  end
  
  def self.admins
    admin_id = Role.find_by_identifier("roles.admin").id
    return search_role_members(admin_id)
  end
  
  def self.school_moderators
    school_moderator_id = Role.find_by_identifier("roles.schools.moderator").id
    return search_role_members(school_moderator_id)
  end

  # find school, city and board moderators
  def self.moderators_of(klass)
    klass_id = ((klass.class == Board || klass.class == School || klass.class == Geo) ? klass.id : klass)
    role = Role.find_by_identifier("roles.#{klass.class.to_s.downcase}.moderator.#{klass_id}")
    return role.nil? ? [] : search_role_members(role.id)
  end

  def joined_groups_topics
    board_ids = self.joined_groups.map{|g| g.discussion.board.id}
    return Topic.in_boards_of(board_ids)
  end
  
  def recent_joined_groups_topics
    joined_groups_topics.find :all, :order => "last_replied_at desc", :limit => 20
  end
  
  def voted?(obj)
    v = Vote.find(:first, :conditions => ['user_id = ? and voteable_id = ? and voteable_type = ? and vote = ?',
                                        self.id, obj.id, obj.class.to_s, true])
    !v.nil?
  end
  
  def random_password(length)
    chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890'
    password = ''
    length.times do |i|
      password << chars[rand(62)]
    end
    password
  end
  
  def reset_password!
    new_password = random_password(7)
    self.password = self.password_confirmation = new_password
    self.save(false)
    Mailer.deliver_new_password_notification(self, new_password)
  end
  
  def participated_topics
    self.posts.find(:all, :conditions => ['topics.deleted_at IS NULL'], :include => [:topic]).map(&:topic).uniq
  end
  
  #只包含在小组参与的话题
  def participated_group_topics
    self.posts.find(:all, :conditions => ['topics.deleted_at IS NULL'], :include => [:topic]).map{|p| p.topic if p.board.talkable_type == "GroupBoard"}.uniq.compact
  end
  
  #只包含在小组发起的话题
  def group_topics
    self.topics.find(:all, :conditions => ["boards.talkable_type = ?","GroupBoard"],:include => [:board])
  end
  
  def teams
    teams_id_list = Following.find(:all,:conditions => {:follower_id => self.id,:followable_type => "Team"}).map(&:followable_id)
    Team.find(:all,:conditions => ["id in (?)",teams_id_list])
  end
  
  def self.archives
    date_func = "extract(year from created_at) as year,extract(month from created_at) as month"
    
    counts = User.find_by_sql(["select count(*) as count, #{date_func} from users where created_at < ? and deleted_at IS NULL group by year,month order by year asc,month asc",Time.now])
    
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

  protected
    # before filter 
    def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
      self.crypted_password = encrypt(password)
    end
      
    def password_required?
      crypted_password.blank? || !password.blank?
    end
    
    def make_activation_code
      self.deleted_at = nil
      self.activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
    end
    
    def do_delete
      self.deleted_at = Time.now.utc
    end

    def do_activate
      @activated = true
      self.activated_at = Time.now.utc
      self.deleted_at = self.activation_code = nil
    end

    def self.search_role_members(role_id)
      u_t = User.table_name.to_s # user table name
      ru_t = "#{Role.table_name}_#{User.table_name}" # roles_users table name
      find_by_sql("select * from #{u_t} inner join #{ru_t} on #{ru_t}.user_id=#{u_t}.id where #{ru_t}.role_id=#{role_id}")
    end
end
