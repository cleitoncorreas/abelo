class Domain < ActiveRecord::Base

  # relationships
  ###############

  belongs_to :owner, :polymorphic => true

  # validations
  #############

  # <tt>name</tt> must be a sequence of word characters (a to z, plus 0 to 9,
  # plus '_'). Letters must be lowercase
  validates_format_of :name, :with => /^([a-z0-9_]+\.)+[a-z0-9_]+$/, :message => _('%{fn} must be composed only of lowercase latters (a to z), numbers (0 to 9) and "_"')

  # checks validations that could not be expressed using Rails' predefined
  # validations. In particular:
  # * <tt>name</tt> must not start with 'www.'
  def validate
    if self.name =~ /^www\./
      self.errors.add(:name, _('%{fn} must not start with www.'))
    end
  end

  # we cannot have two domains with the same name
  validates_uniqueness_of :name

  # businessl logic
  #################

  # finds a domain by its name. The argument <tt>name</tt> can start with
  # "www.", but it will be removed before searching. So searching for
  # 'www.example.net' is exactly the same as searching for just 'example.net'
  def self.find_by_name(name)
    self.find(:first, :conditions => [ 'name = ?', self.extract_domain_name(name) ])
  end

  # turns the argument (expected to be a String) into a domain name that is
  # accepted, by removing any leading 'www.' and turning the downcasing it.
  def self.extract_domain_name(name)
    name.downcase.sub(/^www\./, '')
  end

  # detects the Environment to which this domain belongs, either if it's
  # directly owned by one, or through a profile who owns the domain but belongs
  # to a Environment.
  def environment
    owner
  end

end
