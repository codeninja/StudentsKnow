# Base authenticated class.  Inherit from this class, don't put any app-specific code in here.
# That way we can update this model if auth_generators update.

require 'digest/sha1'
module AuthenticatedBase
  def self.included(base)
    
    base.set_table_name base.name.tableize

    base.validates_presence_of     :login, :email#, :name_first, :name_last
    base.validates_presence_of     :password,                   :if => :password_required?
    base.validates_presence_of     :password_confirmation,      :if => :password_required?
    base.validates_length_of       :password, :within => 4..40, :if => :password_required?
    base.validates_confirmation_of :password,                   :if => :password_required?
    base.validates_length_of       :login,    :within => 3..40, :allow_nil => true
    base.validates_length_of       :email,    :within => 3..100, :allow_nil => true
    base.before_save :encrypt_password
    base.before_create :make_activation_code 

    base.cattr_accessor :current_user
    
    base.extend ClassMethods
  end

  attr_accessor :password, :password_confirmation, :forgotten_password

  module ClassMethods
        
    ## Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
    def authenticate(login=nil, password=nil,fbuid=nil)
      if fbuid
        return u = self.find_by_fbid(fbuid)
      else
        u = self.find_by_login(login) # need to get the salt
        u && u.authenticated!(password) ? u : nil
      end
    end
  
    # Encrypts some data with the salt.
    def encrypt(password, salt)
      Digest::SHA1.hexdigest("--#{salt}--#{password}--")
    end
  
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated!(password)
    if authenticated?(password)
      return true
    else
      #raise AuthenticationFailed #this is not defined anywhere!
    end
  end
  
  def authenticated?(password)
    crypted_password == encrypt(password) and activated!
  end
  
  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end
  
  # These create and unset the fields required for remembering sessions between browser closes
  def remember_me
    remember_me_for 2.years
  end
  
  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end
  
  # Useful place to put the login methods
  def remember_me_until(time)
    self.visits_count = visits_count.to_i + 1
    self.last_login_at = Time.now
    self.remember_token_expires_at = time
    self.remember_token = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end
  
  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end
  
  def encrypt_password
    return if password.blank?
    self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
    self.crypted_password = encrypt(password)
  end
    
  def password_required?
    (crypted_password.blank? || !password.blank?)
  end
  
  def email_required?
    email.blank?
  end

  # Activates the user in the database.
  def activate
    @activated = true
    self.activated_at = Time.now.utc
    self.activation_code = nil
    save(false)
  end

  def activated!
    if activated?
      return true
    else
      raise ActivationRequired
    end
  end
  
  def activated?
    # the existence of an activation code means they have not activated yet
    activation_code.nil?
  end

  # Returns true if the user has just been activated.
  def recently_activated?
    @activated
  end
  
  def make_activation_code
    self.activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
  end

  def forgot_password
      @forgotten_password = true
      self.make_password_reset_code
  end

  #
  def reset_password
      # First update the password_reset_code before setting the 
      # reset_password flag to avoid duplicate email notifications.
      self.password_reset_at = Time.now.utc
      self.password_reset_code = nil
      @reset_password = true
  end  

  #used in user_observer
  def recently_forgot_password?
      @forgotten_password
  end
  def recently_reset_password?
      @reset_password
  end
  def make_password_reset_code
      self.password_reset_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
  end

  def is_admin?
    return false if is_blacklist?
    return self.roles.include?(Role.find_by_ident('admin'))
  end
  
  def is_moderator?
    return false if is_blacklist?
    return self.roles.include?(Role.find_by_ident('moderator')) || is_admin?
  end
  
  def is_user?
    return false if is_blacklist?
    return self.roles.include?(Role.find_by_ident('user')) || is_moderator?  || is_admin?
  end

  def is_blacklist?
    return self.roles.include?(Role.find_by_ident('blacklist'))
  end
  
end
