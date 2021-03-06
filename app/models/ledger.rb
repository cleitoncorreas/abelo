class Ledger < ActiveRecord::Base

  #FIXME verify methods that are not tested

  include Status
  require 'payment_strategy/payment_strategy'
  include PaymentStrategy
  require 'extended_date'

  acts_as_taggable
# FIXME See why the fields make the ferret dind't works
#  acts_as_ferret({:fields => ['description', 'category', 'tags'], :remote => true})
#  acts_as_ferret :remote => true 
  
  attr_accessor :repeat, :interval, :periodicity_id, :needs_fiscal_command

  ############################################
  # Common Relationships and Methods
  ############################################
  belongs_to :category, :class_name => 'LedgerCategory',  :foreign_key => 'category_id'
  belongs_to :schedule_ledger
  belongs_to :bank_account
  belongs_to :organization
  belongs_to :owner, :polymorphic => true
  has_one :printer_command, :as => :owner, :dependent => :destroy

  validates_presence_of :foreseen_value
  validates_presence_of :effective_value, :if => lambda{ |ledger| not ledger.pending? }
  validates_presence_of :bank_account_id
  validates_presence_of :foreseen_date
  validates_presence_of :effective_date, :if => lambda{ |ledger| not ledger.pending? }
  validates_presence_of :schedule_repeat, :if => lambda{ |l| !l.schedule_periodicity_id.blank? or  !l.schedule_interval.blank? }
  validates_presence_of :schedule_periodicity, :if => lambda{ |l| l.schedule_repeat? or !l.schedule_interval.blank? }
  validates_presence_of :schedule_interval, :if => lambda{ |l| l.schedule_repeat? or  !l.schedule_periodicity_id.blank? }
  validates_presence_of :payment_method
  validates_inclusion_of :payment_method, :in => Payment::PAYMENT_TYPES.keys
  validates_presence_of :type_of
  validates_inclusion_of :type_of, :in => Payment::TYPE_OF
  validates_presence_of :owner_id
  validates_presence_of :owner_type
  validates_presence_of :organization_id
  validates_presence_of :category_id, :if => :require_category?

  ############################################
  # Check Specific Relationships and Methods
  ############################################
  belongs_to :bank, :foreign_key => :check_bank_id
  validates_presence_of :check_owner_name, :if => :is_check?
  validates_presence_of :check_bank_id, :if => :is_check?
  validates_presence_of :check_account_agency, :if => :is_check?
  validates_presence_of :check_account_number, :if => :is_check?
  validates_presence_of :check_number, :if => :is_check?
  validates_presence_of :check_cpf, :if => :is_check?
# :if => lambda{|check| check.person_type != PersonType::JURISTIC } FIXME
  validates_presence_of :check_cnpj, :if => :is_check?
#, :if => lambda{|check| check.person_type == PersonType::JURISTIC } FIXME

  ################################################
  # Debit Card Specific Relationships and Methods
  ################################################
  belongs_to :bank, :foreign_key => :automatic_debit_bank_id
#FIXME check the presence of category id for debit, credit, money and check payment types
  validates_presence_of :category_id, :if => :is_debit_card?
  validates_presence_of :automatic_debit_owner_name, :if => :is_debit_card?
  validates_presence_of :automatic_debit_bank_id, :if => :is_debit_card?
  validates_presence_of :automatic_debit_account_agency, :if => :is_debit_card?
  validates_presence_of :automatic_debit_account_number, :if => :is_debit_card?

  ################################################
  # Credit Card Specific Relationships and Methods
  ################################################
  validates_presence_of :credit_card_number, :if => :is_credit_card?
  validates_presence_of :credit_card_validity, :if => :is_credit_card?
  validates_presence_of :credit_card_secutiry_code, :if => :is_credit_card?
  validates_presence_of :credit_card_owner_name, :if => :is_credit_card?
  validates_presence_of :credit_card_cnpj, :if => :is_credit_card?
# :if => lambda{|check| check.person_type == PersonType::JURISTIC } TODO see a way to do that
  validates_presence_of :credit_card_cpf, :if => :is_credit_card?
#:if => lambda{|check| check.person_type != PersonType::JURISTIC } #TODO see a wasy to do that

  # Methods that are defined on payment strategy 
  # Part of the strategy pattern
  delegate :is_check?, :is_money?, :is_credit_card?, :is_debit_card?, :is_add_cash?, :is_remove_cash?, :is_change?, :to => :payment_strategy
  delegate :require_category?, :set_as_done_on_save?, :payment_initialize, :display_class, :create_printer_cmd!, :to => :payment_strategy
  delegate :fiscal_payment_type, :to => :payment_strategy 

  def validate
    if (self.date.nil? ? false : (self.date.to_datetime != Date.today.to_datetime)) and (self.is_add_cash? or self.is_remove_cash? or self.is_change?)
      self.errors.add(:date, I18n.t(:you_cannot_schedule_this_kind_of_ledger))
    end

    if (self.value >= 0) and self.expense?
      self.errors.add(:value, I18n.t(:the_value_must_be_minor_than_zero))
    end

    if (self.expense?) and (self.type_of != Payment::TYPE_OF_EXPENSE)
      self.errors.add(:type_of, I18n.t(:you_cannot_have_an_remove_cash_with_type_different_of_expense))
    end

    if self.is_add_cash? and ( self.type_of != Payment::TYPE_OF_INCOME)
      self.errors.add(:type_of, I18n.t(:you_cannot_have_an_add_cash_with_type_different_of_income))
    end

    if self.printer_command.nil? and self.needs_fiscal_command?
      self.errors.add(t(:you_cannot_realize_money_operations_whithout_create_the_printer_command))
    end

    self.errors.add(:value, I18n.t(:minor_price)) if !self.expense? and (value.nil? || value <= 0.00)

    self.errors.add(:date, I18n.t(:date_cannot_be_set)) unless self[:date].nil?

    if !self.category.nil? and !self.category.payment_methods.include?(self.payment_method)
      self.errors.add(:payment_method, I18n.t(:payment_is_not_in_the_list)) 
    end

    if(!self.date.nil? and (self.date.to_datetime > DateTime.now) and self.done? )
      self.errors.add(:status, I18n.t(:ledger_date_is_in_the_future)) 
    end

    if self.owner.kind_of?(Sale) and self.is_change? and (self.owner.change != self)
      self.errors.add(t(:ledger_only_one_change_for_same_sale)) unless self.owner.change.nil?
    end
  end

  before_validation do |l|
    l.value = ((l.value > 0) ? (l.value * -1) : l.value) if l.is_remove_cash? or l.is_change?
    l.change_signal
    l.type_of = l.category.type_of unless l.category.nil?
    l[:effective_value] ||= l.foreseen_value if l.done?
    l[:effective_date] ||= l.foreseen_date if l.done?
    l.create_printer_cmd!(l) if l.has_fiscal_printer?
  end

  after_create do |ledger|
    ledger.organization.update_tracker('ledger_points', ledger.organization.ledgers.count)
  end

  after_destroy do |ledger|
    ledger.update_balance
    ledger.organization.update_tracker('ledger_points', ledger.organization.ledgers.count) unless ledger.organization.nil?
#FIXME see a way to stop this
#    raise I18n.t(:you_cannot_destroy_sale_ledgers) if ledger.owner.kind_of? Sale
  end

  before_save do |ledger|
    balance = ledger.find_balance_of_month
    ledger.create_balance_of_month if balance.nil? and ledger.done?
    ledger.done if ledger.set_as_done_on_save? and not ledger.has_fiscal_printer?
  end

  after_save do |ledger|
    ledger.update_balance
  end

  after_update do |l|
    if l.schedule_repeat? and !l.scheduled?
      sl = ScheduleLedger.create(:periodicity => l.schedule_periodicity, :start_date => l.date, :interval => l.schedule_interval)
      for n in 1..l.schedule_interval.to_i do
        ledger_schedule = l.dclone
        ledger_schedule.pending!
        ledger_schedule.date = (l.date.kind_of?(Time) ? l.date.to_datetime : l.date) + l.schedule_periodicity.number_of_days * n
        ledger_schedule.schedule_ledger = sl
        ledger_schedule.payment_method = l.payment_method
        ledger_schedule.save
      end
      l.schedule_ledger = sl
      l.save
    end
  end

  def create_balance_of_month
    Balance.create_balance(:date => self.date, :bank_account => self.bank_account)
  end

#FIXME see if this is needed
  def needs_fiscal_command?
   return false unless self.has_fiscal_printer? and self.printer_command.nil? and self.needs_fiscal_command == true
   true
  end

  # Update the value attribute of the balance object with
  # the sum of the ledgers of a month
  # OBS: This method create the a balance instance if it doesn't exist
  def update_balance
    balance = self.find_balance_of_month
    balance.refresh unless balance.nil?
  end

  after_create do |l|
    if l.schedule_repeat? and !l.scheduled?
      sl = ScheduleLedger.create(:periodicity => l.schedule_periodicity, :start_date => l.date, :interval => l.schedule_interval)
      for n in 1..l.schedule_interval.to_i do
        ledger_schedule = l.dclone
        ledger_schedule.pending!
        ledger_schedule.date = (l.date.kind_of?(Time) ? l.date.to_datetime : l.date) + l.schedule_periodicity.number_of_days * n
        ledger_schedule.schedule_ledger = sl
        ledger_schedule.payment_method = l.payment_method
        ledger_schedule.save
      end
      l.schedule_ledger = sl
      l.save
    end
   
    if !l.category.nil? and l.category.number_of_parcels > 1 and !l.scheduled?
      sl = ScheduleLedger.create(:periodicity => l.category.periodicity, :start_date => l.date, :interval => l.category.number_of_parcels)
      l.value = l.value / l.category.number_of_parcels
      l.number_of_parcels = l.category.number_of_parcels
      l.parcel_number = 1
      l.save
      for n in 1..(l.category.number_of_parcels-1) do
        ledger_schedule = l.dclone
        ledger_schedule.pending!
        ledger_schedule.date = (l.date.kind_of?(Time) ? l.date.to_datetime : l.date) + 30 * n
        ledger_schedule.schedule_ledger = sl
        ledger_schedule.payment_method = l.payment_method
        ledger_schedule.save
      end
    end
  end

  after_destroy do |ledger|
    unless ledger.schedule_ledger.nil?
      all_pending = ledger.schedule_ledger.pending_ledgers
      all_pending.delete(ledger)
      ledger.schedule_ledger.destroy if all_pending.blank?
    end
  end

  def initialize(*args)
    super(*args)
    self.organization ||= self.owner if self.owner.kind_of?(Organization)
    self.owner ||= self.organization 
    self.bank_account ||= self.organization.default_bank_account unless self.organization.nil?
    self.payment_initialize(self)
  end

  def payment_strategy
    PaymentStrategy::Factory.new(self.payment_method)
  end

  # Return the balance object of the current month
  def find_balance_of_month
    return if self.bank_account.nil?
    start_date = Date.beginning_of_month(self.date)
    end_date = Date.end_of_month(self.date) + 1
    self.bank_account.balances.find(:first, :conditions => {:date => (start_date..end_date)})
  end

  # Set the status of this ledger for OPEN. It means that the
  # fiscal printer command was sent to the printer.
  def cmd_sent!
    self.status = STATUS_OPEN
  end

  # Set the current status of the ledger to pending. It means that 
  # the fiscal printer received and print the fiscal printer command.
  def cmd_received!(cmd = nil)
    self.status = STATUS_PENDING
  end

  def dclone
    l = self.clone
    l.tag_list = self.tag_list.names
    l
  end

  def schedule_repeat
    self.schedule_ledger.nil? ? self.repeat : true
  end

  def schedule_repeat= value
    self.repeat = (value.to_s == 'true' ? true : false  )
  end

  def schedule_repeat?
    self.schedule_repeat.to_s == 'true' ? true : false
  end

  def scheduled?
    self.schedule_ledger.nil? ? false : true
  end

  def schedule_interval
    self.schedule_ledger.nil? ? self.interval : self.schedule_ledger.interval
  end

  def schedule_interval= value
    self.interval = value
  end

  def ledgers_scheduled
    return [] if self.schedule_ledger.nil?
    self.schedule_ledger.ledgers.select{|l| l != self}
  end

  #FIXME Make this test
  def unschedule!(ledger)
    return nil if self.schedule_ledger.nil?
    removed = self.schedule_ledger.ledgers.destroy(ledger)
    if self.schedule_ledger.ledgers.one? and self.schedule_ledger.ledgers.include?(self)
      self.schedule_ledger.destroy
    end
    removed
  end

  #FIXME Make this test
  def unschedule_all!
    s = self.schedule_ledger
    self.ledgers_scheduled.map do |ledger|
      self.unschedule!(ledger)
    end
  end

  def payment_type
    self.payment_method
  end

  def reload
    Ledger.find(self.id)
  end

  # Return the value sum of income ledgers passed as parameter
  def self.total_income(ledgers, balance=0)
    total = 0
    ledgers.collect{ |l| total = total + (l.income? ? l.value : 0) }
    total + (balance || 0)
  end

  # Return the value sum of expense ledgers passed as parameter
  def self.total_expense(ledgers, balance=0)
    total = 0
    ledgers.collect{ |l| total = total + (l.expense? ? l.value : 0) }
    total + (balance || 0)
  end


  # Check if the current ledger is a income
  def income?
    self.type_of == Payment::TYPE_OF_INCOME
  end

  
  # Check if the current ledger is a expense 
  # FIXME make this test
  def expense?
    (self.category.expense? unless self.category.nil?) or self.is_remove_cash? or self.is_change?
  end

  #FIXME make this test
  def change_signal
    return if self.category.nil?
    self[:foreseen_value] = self.value * -1 if ((self.foreseen_value || 0) > 0 and self.expense? )
    self[:effective_value] = self.value * -1 if ((self.effective_value || 0) > 0 and self.expense?)
  end

  # Search for ledgers that contain any data that match with the 
  # query passed as first arguments. 
  # As the second argument some options can be passed, the options 
  # are those permited by acts_as_ferret plugin
  #
  # EX: 
  #   
  #   Ledger.full_text_search('car', :limit => 2)
  #
  # The example above  will return 2 (two) ledgers which contains
  # the word 'car' in his field
  def self.full_text_search(q, options = {})
    default_options = {:limit => :all, :offset => 0}
    options = default_options.merge options
    self.find_by_contents(q, options)
  end
  
  def schedule_periodicity_id= value
    self.periodicity_id = value
  end

  def schedule_periodicity_id
    self.schedule_ledger.nil? ? self.periodicity_id : self.schedule_ledger.periodicity_id
  end

  def schedule_periodicity= value
    self.schedule_periodicity_id=  value.kind_of?(Periodicity) ? value.id : value
  end

  def schedule_periodicity
    if self.schedule_ledger.nil? 
      self.organization.periodicities.find(self.schedule_periodicity_id) unless self.organization.nil? or self.schedule_periodicity_id.blank?
    else
      self.schedule_ledger.periodicity
    end
  end

  def has_fiscal_printer?
    self.organization.nil? ? false : self.organization.has_fiscal_printer?
  end

  def is_fiscal_operation?
    return false unless self.has_fiscal_printer?
    self.is_add_cash? or self.is_remove_cash? or self.is_change? or self.owner.kind_of?(Sale)
  end

  def value= value
    return if value.nil?
    value = value.kind_of?(String) ? (value.gsub!('.', ''); value.gsub(',','.')).to_f : value
    value = ((value > 0) ? (value * -1) : value) if self.expense?
    self[:foreseen_value] = value if self.pending? or self.foreseen_value.nil?
    self[:effective_value] = value if self.done?
  end

  def value
    value = self.pending? ? self[:foreseen_value] :  self[:effective_value]
    value ||= 0
  end

  def date
    self.pending? ? self[:foreseen_date] : self[:effective_date]
  end

  def date= date  
    self.pending? ? self[:foreseen_date] = date : self[:foreseen_date] ||= date
    self[:effective_date] = date unless self.pending?
  end

  def update_date
  end

  def cancel!
    self.status = STATUS_CANCELLED
  end

  def cancel?
    self.status == STATUS_CANCELLED
  end

  def confirm_cancel!
    self.cancel!
    self.save
  end

  # Set a ledger as done and update the effective_date and effective_value attributtes
  # with the foreseen_date and foreseen_value attributes respectively when the attributes 
  # are not set.
  def done
    self[:effective_date] ||= self.foreseen_date
    self[:effective_value] ||= self.foreseen_value
    self.status = STATUS_DONE
  end

  # The same as done function but saves the value after done actions
  def done!
    self.done
    self.save
  end

  def done?
    self.status == STATUS_DONE
  end

  def pending!
    self.status = STATUS_PENDING
  end

  def pending?
    self.status == STATUS_PENDING or self.status == STATUS_OPEN
  end

#  #This method cannot be access directly. 
#  #You have to access the date method and this method
#  #set the correct value of foreseen_date attribute
  def foreseen_date= date
    raise I18n.t(:this_function_cannot_be_accessed_directly)
  end

#  #This method cannot be access directly. 
#  #You have to access the value method and this method
#  #set the correct value of foreseen_value attribute
  def foreseen_value= value
    raise I18n.t(:this_function_cannot_be_accessed_directly)
  end

#  #This method cannot be access directly. 
#  #You have to access the date method and this method
#  #set the correct value of effective_date attribute
  def effective_date= date
    raise I18n.t(:this_function_cannot_be_accessed_directly)
  end

#  #This method cannot be access directly. 
#  #You have to access the value method and this method
#  #set the correct value of effective_value attribute
  def effective_value= value
    raise I18n.t(:this_function_cannot_be_accessed_directly)
  end

end
