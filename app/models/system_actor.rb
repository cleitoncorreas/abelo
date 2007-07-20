class SystemActor < ActiveRecord::Base

  #relationships 
  belongs_to :organization
  has_many :contacts 

  #validations
  validates_presence_of :name, :organization_id, :category_id
  validates_as_cnpj :cnpj
  validates_as_cpf :cpf
  validates_presence_of :name, :email
  validates_uniqueness_of :cnpj, :scope => :organization_id, :if => lambda { |user| ! user.cnpj.blank? }, :message => _('This %{fn} already exist')
  validates_uniqueness_of :cpf, :scope => :organization_id, :if => lambda { |user| ! user.cpf.blank? }, :message => _('This %{fn} already exist')

  def validate
    if ((! self.cpf.blank?) && (! self.cnpj.blank?)) || (self.cpf.blank? && self.cnpj.blank?)
      errors.add('cnpj', 'Either %{fn} or CPF must be filled, and they cannot be filled at the same time.')
    end
  end


  # maps an actor to an human-readable string
  def self.describe(actor)
    return {
      'customer' => _('Customer'),
      'worker' => _('Worker'),
      'supplier' => _('Supplier')
    }[actor]
  end


end