require 'digest/sha1'
class User < ActiveRecord::Base
    
  USERTYPES = [ "admin-mx", "parent", "student"]
  
  # Virtual attribute for the unencrypted password
  attr_accessor :password

  validates_presence_of     :login
  validates_presence_of     :password,                   :if => :password_required?
  validates_length_of       :password, :within => 1..40, :if => :password_required?
  validates_length_of       :login,    :within => 1..40
  validates_uniqueness_of   :login, :case_sensitive => false
  #validates_uniqueness_of   :login, :case_sensitive => false
  before_save :encrypt_password
  
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :password, :user_type, :first_name, :last_name, :crypted_password, :type, :membership_expires, :status

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    u = find_by_login(login) # need to get the salt
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
    # sk change - keep passwords in the clear  crypted_password == encrypt(password)
    crypted_password == password
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
    save(:validate => false)  #save(false)
  end

  # Returns true if the user has just been activated.
  def recently_activated?
    @activated
  end

    def get_crypted_password
      return crypted_password 
    end
    
  protected
    # before filter 
    def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
      # sk change - keep paqsswords in the clear  self.crypted_password = encrypt(password)
      self.crypted_password = password
   end
      
    def password_required?
      crypted_password.blank? || !password.blank?
    end
    

end
