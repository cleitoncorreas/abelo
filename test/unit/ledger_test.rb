require File.dirname(__FILE__) + '/../test_helper'

class LedgerTest < Test::Unit::TestCase

  PAYMENT_METHODS_TEST = %w[
    check
    credit_card
    debit_card
    money
  ]


  fixtures :bank_accounts, :categories, :ledgers, :periodicities, :ledger_categories

  def setup
    @organization = Organization.find(:first)
    @periodicity = Periodicity.create!(:organization => @organization, :name => 'Some', :number_of_days => 10)
    @ledger_category = LedgerCategory.find(:first)
    @ledger = Ledger.find(:first)
  end

  def test_setup
    assert @ledger.valid?
    assert @organization.valid?
    assert @periodicity.valid?
    assert @ledger_category.valid?
  end

  def test_money_class_is_associated_to_a_valid_ledger_category
    category = LedgerCategory.create!(:name => 'Some', :is_operational => false, :organization => Organization.find(:first), :type_of => 'I', :payment_methods => ['money'] )

    l = Ledger.new_ledger(:owner => @organization, :value => 10, :date => Date.today, :category => category, :bank_account_id => BankAccount.find(:first), :payment_method => 'money')

    assert l.save
    ledger_id = l.id
    assert Payment.income?(category.type_of)
    ledger = Ledger.find(ledger_id) 
    assert_equal Money, ledger.class
  end

  def test_money_class_cannot_be_associated_to_a_invalid_ledger_category
    category = LedgerCategory.create!(:name => 'Some', :is_operational => false, :organization => Organization.find(:first), :type_of => 'I', :payment_methods => ['money'] )

    l = Ledger.new_ledger(:owner => @organization, :value => 10, :date => Date.today, :category => category, :bank_account_id => BankAccount.find(:first), :payment_method => 'check')

    l.valid?
    assert l.errors.invalid?(:payment_method)
  end



  def test_validates_presence_of_bank_account
    l = Ledger.new_ledger
    l.valid?
    assert l.errors.invalid?(:bank_account_id)
    l.bank_account = BankAccount.find(:first)
    l.valid?
    assert !l.errors.invalid?(:bank_account_id)
  end

  def test_validates_presence_of_owner
    l = Ledger.new_ledger
    l.valid?
    assert l.errors.invalid?(:owner)
    l.owner = @organization
    l.valid?
    assert !l.errors.invalid?(:owner_id)
    assert !l.errors.invalid?(:owner_type)
  end


  def test_creation_of_ledgers_when_a_schedule_ledgers_is_needed
    Ledger.delete_all

    l = Ledger.new_ledger
    l.owner = @organization
    l.category = @ledger_category
    l.value = 300
    l.description = 'some description'
    l.tag_list = 'tag_test'
    l.date = Date.today
    l.bank_account = BankAccount.find(:first)
    l.schedule_repeat = true
    l.schedule_periodicity = Periodicity.find(:first)
    l.schedule_interval = 2
    l.payment_method = 'money'
    
    assert l.save!
    assert_equal 3, Ledger.count
  end

  def test_creation_of_ledgers_when_a_schedule_ledgers_is_needed_but_the_ledger_was_not_created
    Ledger.delete_all

    l = Ledger.new_ledger
    l.category = LedgerCategory.find(:first)
    l.value = nil #value is missing 
    l.description = 'some description'
    l.tag_list = 'tag_test'
    l.date = Date.today
    l.bank_account = BankAccount.find(:first)
    l.schedule_repeat = true
    l.schedule_periodicity = Periodicity.find(:first)
    l.schedule_interval = 2
    
    assert !l.save
    assert_equal 0, Ledger.count
  end

  def test_presence_of_schedule_interval_when_schedule_repeat_and_schedule_periodicity_are_present
    l = Ledger.new_ledger
    l.schedule_repeat = true
    l.schedule_periodicity= Periodicity.find(:first)
    l.valid?
    assert l.errors.invalid?(:schedule_interval)
  end

  def test_presence_of_schedule_interval_when_schedule_repeat_is_present
    l = Ledger.new_ledger
    l.schedule_repeat = true
    l.valid?
    assert l.errors.invalid?(:schedule_interval)
  end

  def test_presence_of_schedule_interval_when_schedule_periodicity_is_present
    l = Ledger.new_ledger
    l.schedule_periodicity= Periodicity.find(:first)
    l.valid?
    assert l.errors.invalid?(:schedule_interval)
  end

  def test_presence_of_schedule_periodicity_when_schedule_repeat_and_schedule_interval_are_present
    l = Ledger.new_ledger
    l.schedule_repeat = true
    l.schedule_interval= 1
    l.valid?
    assert l.errors.invalid?(:schedule_periodicity)
  end

  def test_presence_of_schedule_periodicity_when_schedule_repeat_is_present
    l = Ledger.new_ledger
    l.schedule_repeat = true
    l.valid?
    assert l.errors.invalid?(:schedule_periodicity)
  end

  def test_presence_of_schedule_periodicity_when_schedule_interval_is_present
    l = Ledger.new_ledger
    l.schedule_interval= 1
    l.valid?
    assert l.errors.invalid?(:schedule_periodicity)
  end

  def test_presence_of_schedule_repeat_when_schedule_periodicity_and_schedule_interval_are_not_present
    l = Ledger.new_ledger
    l.valid?
    assert !l.errors.invalid?(:schedule_repeat)
  end

  def test_presence_of_schedule_repeat_when_schedule_periodicity_is_present
    l = Ledger.new_ledger
    l.valid?
    assert !l.errors.invalid?(:schedule_repeat)
    l.schedule_periodicity = Periodicity.find(:first)
    l.valid?
    assert l.errors.invalid?(:schedule_repeat)
  end

  def test_presence_of_schedule_repeat_when_schedule_interval_is_present
    l = Ledger.new_ledger
    l.valid?
    assert !l.errors.invalid?(:schedule_repeat)
    l.schedule_interval = 1
    l.valid?
    assert l.errors.invalid?(:schedule_repeat)
  end

  def test_presence_of_schedule_repeat_when_schedule_interval_and_schedule_periodicity_are_present
    l = Ledger.new_ledger
    l.valid?
    assert !l.errors.invalid?(:schedule_repeat)
    l.schedule_interval = 1
    l.schedule_periodicity = Periodicity.find(:first)
    l.valid?
    assert l.errors.invalid?(:schedule_repeat)
  end
  def test_precense_of_category
    c = LedgerCategory.new(:name => 'Some category', :organization_id => 1, :type_of => 'I', :payment_methods => ['money'])
    c.save!
    l = Ledger.new_ledger
    l.valid?
    assert l.errors.invalid?(:category_id)
    l.category = c 
    l.valid?
    assert !l.errors.invalid?(:category_id)
  end

  def test_precense_of_foreseen_date
    l = Ledger.new_ledger
    l.valid?
    assert l.errors.invalid?(:foreseen_date)
    assert_raise(RuntimeError){l.foreseen_date = 1}
    l.date = Date.today
    l.valid?
    assert !l.errors.invalid?(:foreseen_date)
  end

  def test_precense_of_effective_date
    l = Ledger.new_ledger
    l.valid?
    assert l.errors.invalid?(:effective_date)
    assert_raise(RuntimeError){l.effective_date = 1}
    l.date = Date.today
    l.valid?
    assert !l.errors.invalid?(:effective_date)
  end
  
  def test_precense_of_effective_date_when_is_foreseen
    l = Ledger.new_ledger
    l.is_foreseen = true
    l.date =  Date.today
    l.valid?
    assert !l.errors.invalid?(:effective_date)
    assert_raise(RuntimeError){l.effective_date = Date.today}
  end


  def test_precense_of_foressen_value
    l = Ledger.new_ledger
    l.valid?
    assert l.errors.invalid?(:foreseen_value)
    assert_raise(RuntimeError){l.foreseen_value = 1}
    l.value = 1
    l.valid?
    assert !l.errors.invalid?(:foreseen_value)
  end

  def test_precense_of_effective_value
    l = Ledger.new_ledger
    l.valid?
    assert l.errors.invalid?(:effective_value)
    assert_raise(RuntimeError){l.effective_value = 1}
    l.value = 1
    l.valid?
    assert !l.errors.invalid?(:effective_value)
  end

  def test_precense_of_effective_value_when_is_foreseen
    l = Ledger.new_ledger
    l.is_foreseen = true
    l.value = 1
    l.valid?
    assert !l.errors.invalid?(:effective_value)
    assert_raise(RuntimeError){l.effective_value = 1}
  end

  def test_numericality_of_value
    l = Ledger.new_ledger
    l.value = 'a'
    l.valid?
    assert l.errors.invalid?(:value)
    l.value = ''
    l.valid?
    assert l.errors.invalid?(:value)
    l.value = 12
    l.valid?
    assert !l.errors.invalid?(:value)
  end

  def test_value_must_be_greater_then_zero
    l = Ledger.new_ledger
    l.value = 0.0
    l.valid?
    assert l.errors.invalid?(:value)
    l.value = -1
    l.valid?
    assert l.errors.invalid?(:value)
    l.value = 0.01
    l.valid?
    assert !l.errors.invalid?(:value)
  end


  def test_schedule_mandatory_fields_param_schedule_repeat_when_all_informations_correct
    ledger = @ledger
    ledger.schedule_repeat = true
    ledger.schedule_periodicity = @periodicity
    ledger.schedule_interval = 34
    ledger.valid?
    assert !ledger.errors.invalid?(:schedule_repeat)

  end

  def test_schedule_mandatory_fields_param_schedule_repeat_when_periodicity_is_nil
    ledger = @ledger
    ledger.schedule_repeat = true
    ledger.schedule_periodicity = nil
    ledger.schedule_interval = 34
    ledger.valid?
    assert !ledger.errors.invalid?(:schedule_repeat)
  end

  def test_schedule_mandatory_fields_param_schedule_repeat_when_interval_is_nil
    ledger = @ledger
    ledger.schedule_repeat = true
    ledger.schedule_periodicity = @periodicity
    ledger.schedule_interval = nil
    ledger.valid?
    assert !ledger.errors.invalid?(:schedule_repeat)
  end

  def test_schedule_mandatory_fields_param_schedule_repeat_when_interval_and_periodicity_is_nil
    ledger = @ledger
    ledger.schedule_repeat = true
    ledger.schedule_periodicity = nil
    ledger.schedule_interval = nil
    ledger.valid?
    assert !ledger.errors.invalid?(:schedule_repeat)

    ledger.schedule_repeat = false
    ledger.schedule_periodicity = nil
    ledger.schedule_interval = nil
    ledger.valid?
    assert !ledger.errors.invalid?(:schedule_repeat)
  end

  def test_schedule_mandatory_fields_param_schedule_repeat_true_and_interval_and_periodicity_exist
    ledger = @ledger
    ledger.schedule_periodicity = @periodicity
    ledger.schedule_interval = 34
    ledger.schedule_repeat = false
    ledger.valid?
    assert ledger.errors.invalid?(:schedule_repeat)
  end

  def test_schedule_mandatory_fields_param_schedule_repeat_false_and_periodicity_is_nil
    ledger = @ledger
    ledger.schedule_periodicity = nil
    ledger.schedule_interval = 34
    ledger.schedule_repeat = false
    ledger.valid?
    assert ledger.errors.invalid?(:schedule_repeat)
  end

  def test_schedule_mandatory_fields_param_schedule_repeat_false_and_interval_is_nil
    ledger = @ledger
    ledger.schedule_periodicity = @periodicity
    ledger.schedule_interval = nil
    ledger.schedule_repeat = false
    ledger.valid?
    assert ledger.errors.invalid?(:schedule_repeat)
  end

  def test_value_is_not_negative
    p = Ledger.new_ledger
    p.valid?
    assert p.errors.invalid?(:value)
    p.value = -1.0
    p.valid?
    assert p.errors.invalid?(:value)    
  end

  def test_value_did_not_return_nil
    p = Ledger.new_ledger
    p.value = nil
    assert_not_nil p.value
  end

  def test_payment_methods_are_describe
    PAYMENT_METHODS_TEST.each do |p|
      assert_not_equal p, Payment.describe_payment(p)
    end
  end

  def test_payment_methods
    assert_equal PAYMENT_METHODS_TEST, Payment::PAYMENT_METHODS
  end

end
