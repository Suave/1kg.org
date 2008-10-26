class User < ActiveRecord::Base
  acts_as_user
  
  acts_as_encrypts_password
  
  validates_length_of :password, :minimum => 8
  
  class << self
    # Searches for the user record with the given email and password and
    # returns a User instance for it. Returns nil if no user with the given
    # credentials could be found.
    def find_by_credentials(email, password)
      user = User.find(:first, :conditions => [ 'email = ?', email ])

      if not user.nil? and user.password_equals?(password) then
        user
      else
        nil
      end
    end
  end
end
