require "digest/sha1"

class User < Person
  # Virtual attribute for the unencrypted password
  attr_accessor :password
  attr_accessor :organization_profile
  attr_accessor :template
  attr_accessor :template_valid

  validates_presence_of     :login, :email
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :login,    :within => 3..40
  validates_length_of       :email,    :within => 3..100
  validates_uniqueness_of   :login, :email, :case_sensitive => false

  before_save :encrypt_password

  has_many :profiles
  has_many :organizations, :through => :profiles
  has_many :ledgers
  
  before_destroy :destroy_profiles

  acts_as_ferret

  after_create do |user|
    transaction do
      profile = Profile.new
      profile.name = user.template
      profile.template = user.template
      profile.organization = user.organization_profile
      profile.user_id = user.id
      profile.save! 
    end  
  end

  def validate
    unless template_valid?
      self.errors.add(:template, _("You don't have permissions to create a user with this template %s ") % self.template)
    end
  end

  def template
    return nil if self.organization_profile.nil?
    if !self.profiles.nil? and !self.organization_profile.blank?
      p = self.profiles.find_by_organization_id(self.organization_profile.id)
    end
    p.template unless p.nil?
  end

  def template_valid?
    self.template_valid == true ? true : false
  end

  # Destroy all profiles before destroy the user 
  def destroy_profiles
    self.profiles.destroy_all 
  end

  # Search the users by all fields of model
  def self.full_text_search(q, options = {})
    default_options = {:limit => :all, :offset => 0}
    options = default_options.merge options
    results = self.find_by_contents(q, options)
    return results
  end
 
  # Tells if this user has access to the <tt>location</tt> passed as parameter
  # (as a URL hash, just like everywhere in Rails).
  #
  # Works by checking if any of the user's profiles gives her the needed
  # permission.
  def allowed_to?(locations)
    if locations.kind_of?(Array)
      self.profiles.any? do |profile|
        profile.allows_all?(locations)
      end
    else
      self.profiles.any? do |profile|
        profile.allows?(locations)
      end
    end
  end

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    u = find_by_login(login) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  def organization
    self.organizations.find(:first)
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
    self.remember_token_expires_at = 2.weeks.from_now.utc
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
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

end
