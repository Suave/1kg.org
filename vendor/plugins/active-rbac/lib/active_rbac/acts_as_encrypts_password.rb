#--
# Project:   active_rbac 
# File:      lib/active_rbac/acts_as_encrypts_password.rb
# Author:    Manuel Holtgrewe <purestorm at ggnore dot net>
# Copyright: (c) 2007 by Manuel Holtgrewe
# License:   MIT License as follows:
#
# Permission is hereby granted, free of charge, to any person obtaining 
# a copy of this software and associated documentation files (the 
# "Software"), to deal in the Software without restriction, including 
# without limitation the rights to use, copy, modify, merge, publish, 
# distribute, sublicense, and/or sell copies of the Software, and to permit
# persons to whom the Software is furnished to do so, subject to the 
# following conditions:
#
# The above copyright notice and this permission notice shall be included 
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
# OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. 
#++

require 'digest/sha1'

module ActsAsEncryptsPassword
  module ActsAsMethods
    # Calling this method in ActiveRecord::Base then the class will be extended by the
    # aspect that it has a password that gets encrypted. The table that the ActiveRecord
    # class represents must provide a column for the encrypted password, a password salt, 
    # the password hash type. By default, this columns are assumed to have the names
    # "password", "password_salt" and "password_hash_type".
    #
    # The ActiveRecord must thus provide the following attributes:
    #
    # password:: the password of the record
    # password_salt:: the salt to use to make the password hash more secure, randomly
    #                 and automatically generated, read only
    # password_hash_type:: the password hash type to use, currently this is fixed to be
    #                      'sha1', read only
    #
    # The class will get the following new attribute (if you use the defaults mentioned
    # above).
    #
    # password_confirmation:: confirmation of the password, must equal password, either
    #                         both can have been added or none
    #
    # and the following new methods
    #
    # acts_as_encrypts_password?:: returns true
    # update_password(pass):: sets password and password_confirmation to pass
    # password_new?:: returns true if the password has been set after the record
    #                 has been retrieved from the database.
    # password_equals?(pass):: returns true if the record's password equals pass
    # self.valid_password_hash_types:: the names of all valid password hash types
    #
    # The password will automatically be encrypted when the user object is being saved
    # and the password has changed.
    #
    # The record will not validate if only one of password and password_confirmation
    # has been set or both are not equal. password_confirmation is not persisted into
    # the database but only kept in the object
    #
    # The following migration could be used to create a "users" table with the appropriate
    # columns:
    #
    #     class CreateUsers < ActiveRecord::Migration
    #       def self.up
    #         create_table :users do |t|
    #           t.column :password,      :string, :limit => 128, :null => false # sha-512 ready
    #           t.column :password_salt, :string, :limit => 100, :null => false
    #           t.column :password_hash_type, :string, :limit =>  10, :null => false
    #         end
    #       end
    # 
    #       def self.down
    #         drop_table :users
    #       end
    #     end
    #
    # The attributes :password, :password_confirmation, :password_hash_type and
    # :password_salt will be marked by "attr_protected".
    # 
    #--
    # acts_as_password interprets (NOT YET, TODO) the following parameters:
    # 
    # :password_column:: The name of the column for the password.
    # :password_salt_column:: The name of the column for the password salt.
    # :password_hash_type_column:: The name of the column for the password hash type.
    #
    # An example of acts_as_encrypts_password:
    #
    #     class User < ActiveRecord::Base
    #       acts_as_encrypts_password :password_column => 'passwd', :password_salt_column => 'salt',
    #                            :password_hash_type_column => 'hash_type'
    #     end
    #++
    #--
    # * TODO: Move all internal state keeping into @aaep_data as documented.
    #++
    def acts_as_encrypts_password(params={})
      # Include the behaviour (i.e. the actual mixin methods).
      include ActsAsEncryptsPassword::Behaviour

      # Mark some attributes as not auto-settable.
      attr_protected :password, :password_confirmation, :password_salt, :password_hash_type
      
      # Make sure that the new passwords equal.
      validates_each(:password) do |record, attr, value|
        if record.password_new? and not record.password.nil? and record.password != record.password_confirmation then
          record.errors.add(:password, 'must match the confirmation') 
        end
      end
      
      # Make sure that the password is given.
      validates_presence_of :password
      
      # Encrypt the password after validation. encrypt_password comes from 
      # ActsAsEncryptsPassword::Behaviour.
      after_validation :encrypt_password

      #--
      # We cannot update password_hash_type from the outside anyway. So comment it out.
      # validates_inclusion_of :password_hash_type,
      #   :in => ActsAsEncryptsPassword::Behaviour.valid_password_hash_types,
      #   :message => 'Invalid password hash type.'
      #++
      
      nil
    end
  end
  
  module Behaviour
    # -----------------------------------------------------------------------------
    # Methods password=, password_confirmation= should update @password_new.
    
    # Overriding the default accessor to update @password_new on setting this
    # property.
    def password=(value)
      write_attribute(:password, value)
      @password_new = true
    end

    # The writer for the password confirmation will set password_new? to true.
    def password_confirmation=(value)
      @password_confirmation = value
      @password_new = true
    end

    # Reader for the password confirmation.
    attr_reader :password_confirmation

    # Returns true if and only if the password has been set and the record has not
    # bee saved since.
    def password_new?
      # The password is considered to be new if it has not been set yet and the
      # record is not stored in the database at the moment.
      if @password_new.nil? then 
        @password_new = new_record?
      end
        
      @password_new
    end

    # Method to update the password and confirmation at the same time. Call
    # this method when you update the password from code and don't need 
    # password_confirmation - which should really only be used when data
    # comes from forms. 
    #
    # A ussage example:
    #
    #   user = User.find(1)
    #   user.update_password "n1C3s3cUreP4sSw0rD"
    #   user.save!
    #
    def update_password(pass)
      self.password_confirmation = pass
      self.password = pass
    end

    # This method checks whether the given value equals the password. The given value
    # will be hashed with the user's current password salt and hash type if the password
    # is already encrypted and just plainly compared in all other cases.
    # Returns a boolean.
    def password_equals?(value)
      if password_new? then
        value.to_s == self.password.to_s
      else
        hash_string(value.to_s) == self.password.to_s
      end
    end

    # -----------------------------------------------------------------------------
    # Writing the password hash type and salt is forbidden from the outside.
    
    # Do not allow calls to password_hash_type=.
    def password_hash_type=(value)
      raise NameError, "password_hash_type=(value) is not allowed to be called on #{self}:#{self.class}"
    end

    # Do not allow calls to password_salt=.
    def password_salt=(value)
      raise NameError, "password_salt=(value) is not allowed to be called on #{self}:#{self.class}"
    end

    #--
    # We cannot change password_hash_type from the outside anyway so comment this out.
    # Return all valid password hash types. At the moment, this is not important since
    # password_hash_type is read only anyway.
    # def self.valid_password_hash_types
    #   [ 'sha1' ]
    # end
    #++

    protected

      # This method writes the attribute "password" to the hashed version. It is 
      # called in the after_validation hook set by the "after_validation" command
      # above.
      # The password is only encrypted when no errors occured on validation, the
      # password is new and the password is not nil.
      # This method also sets the "password_salt" property's value used in 
      # User#hash_string.
      # After encryption, the password's "new" state is reset and the confirmation
      # is cleared. The password hash's type will also be set to "not new" since
      # we get problems with double validation (as it happens when using save!)
      # otherwise.
      def encrypt_password
        # initialize password_hash_type if required
        write_attribute(:password_hash_type, 'sha1') if read_attribute(:password_hash_type).nil?

        if errors.count == 0 and password_new? and not password.nil? then
          # generate a new 10-ychar long hash only Base64 encoded so things are compatible
          write_attribute(:password_salt, [Array.new(10){rand(256).chr}.join].pack("m")[0..9]);

          # write encrypted password to object property
          write_attribute(:password, hash_string(password))

          # mark password as "not new" any more
          @password_new = false
          @password_confirmation = nil
        
          # mark the hash type as "not new" any more
          @new_hash_type = false
        end
      end
      
      # Hashes the given parameter by the selected hashing method. It uses the
      # "password_salt" property's value to make the hashing more secure.
      def hash_string(value)
        return case password_hash_type
               when 'sha1' then Digest::SHA1.hexdigest(value + self.password_salt)
               when 'md5'  then Digest::MD5.hexdigest(value + self.password_salt)
               end
      end 
  end
end