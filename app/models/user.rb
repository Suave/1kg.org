require 'digest/sha1'
class User < ActiveRecord::Base
  acts_as_user
  # Virtual attribute for the unencrypted password
  attr_accessor :password

  validates_presence_of     :login, :message => "用户名不能为空"
  validates_presence_of     :email, :message => "邮件地址不能为空"
  validates_presence_of     :password,                   :if => :password_required?, :message => "密码不能为空"
  validates_presence_of     :password_confirmation,      :if => :password_required?, :message => "确认密码不能为空"
  validates_length_of       :password, :within => 4..40, :if => :password_required?, :message => "密码长度在4-40个字符之间"
  validates_confirmation_of :password,                   :if => :password_required?, :message => "两次输入的密码不一致"
  validates_length_of       :login,    :within => 2..40, :message => "用户名长度在2-40个字符之间"
  validates_length_of       :email,    :within => 3..100, :message => "邮件地址长度在3-100个字符之间"
  validates_uniqueness_of   :email, :case_sensitive => false, :message => "邮件地址已被占用"
  
  file_column :avatar, :magick => {
                              :geometry => "72x72>",
                              :versions => {"small" => "16x16", "medium" => "32x32", "large" => "48x48"}
                            }
  
  belongs_to :geo
  has_one :profile
  
  has_many :submitted_activities, :class_name => "Activity"
  has_many :participations
  has_many :participated_activities, :through => :participations, :source => :activity
  
  has_many :submitted_schools, :class_name => "School"
  has_many :visiteds
  has_many :visited_schools, :through => :visiteds, :source => :school
  
  has_many :topics
  
  has_many :shares
  
  #add relationship between messages			
  has_many :sent_messages, 			:class_name => "Message", 
																:foreign_key => "author_id"

	has_many :received_messages, 	:class_name => "MessageCopy", 
															 	:foreign_key => "recipient_id"

	has_many :unread_messages, 		:class_name 		=> "MessageCopy",
														 		:conditions 		=> {:unread => true},
														 		:foreign_key 	=> "recipient_id"
														 		
	has_many :neighborhoods
	has_many :neighbors, :through => :neighborhoods
  
  has_many :memberships, :dependent => :destroy
  has_many :joined_groups, :through => :memberships, :source => :group 
  
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
  
  def has_neighbor?(user)
    user.neighbors.include?(self)
  end
  
  def neighbor_addable_by?(user)
    logger.info("CURRENT_USER: #{user.inspect}")
    (user != nil) and (id != user.id) and not has_neighbor?(user)
  end
  
  def neighbor_removeable_by?(user)
    (user != nil) and (id != user.id) and has_neighbor?(user)
  end
  
  def self.recent_citizens
    find(:all, :conditions => ["geo_id IS NOT NULL and state='active'"],
               :order => "users.created_at desc",
               :include => [:geo],
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
  
  
  def self.moderators_of(board)
    board_id = (board.class == Board ? board.id : board)
    role_id = Role.find_by_identifier("roles.board.moderator.#{board_id}").id
    return search_role_members(role_id)
  end
  
  def self.archives
    date_func = "extract(year from created_at) as year,extract(month from created_at) as month"
    
    counts = User.find_by_sql(["select count(*) as count, #{date_func} from users where created_at < ? group by year,month order by year asc,month asc",Time.now])
    
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
