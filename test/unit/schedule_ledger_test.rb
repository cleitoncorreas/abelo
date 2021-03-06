require File.dirname(__FILE__) + '/../test_helper'

class ScheduleLedgerTest < Test::Unit::TestCase

  def setup
    @organization = create_organization
    @periodicity = create_periodicity
    @bank = create_bank
    @bank_account = create_bank_account
    @ledger_category = create_ledger_category
  end

  def create_schedule
    ScheduleLedger.create!(:periodicity => @periodicity, :start_date => DateTime.now, :interval => 3)
  end

  def test_presence_of_periodicity_id
    sl = ScheduleLedger.new
    sl.valid?
    assert sl.errors.invalid?(:periodicity_id)
    sl.periodicity = @periodicity
    sl.valid?
    assert !sl.errors.invalid?(:periodicity_id)    
  end

  def test_presence_of_start_date
    sl = ScheduleLedger.new
    sl.valid?
    assert sl.errors.invalid?(:start_date)
    sl.start_date =  DateTime.now
    sl.valid?
    assert !sl.errors.invalid?(:start_date)    
  end

  def test_start_date_on_past_date
    sl = ScheduleLedger.new
    sl.start_date =  DateTime.now - 1
    sl.valid?
    assert sl.errors.invalid?(:start_date)    
  end

  def test_start_date_in_current_date
    sl = ScheduleLedger.new
    sl.start_date =  DateTime.now
    sl.valid?
    assert !sl.errors.invalid?(:start_date)    
  end

  def test_start_date_on_future_date
    sl = ScheduleLedger.new
    sl.start_date =  DateTime.now + 1
    sl.valid?
    assert !sl.errors.invalid?(:start_date)    
  end


  def test_presence_of_interval
    sl = ScheduleLedger.new
    sl.valid?
    assert sl.errors.invalid?(:interval)
    sl.interval = 2
    sl.valid?
    assert !sl.errors.invalid?(:interval)    
  end

  def test_numericality_of_interval
    sl = ScheduleLedger.new
    sl.valid?
    assert sl.errors.invalid?(:interval)
    sl.interval = 'some'
    sl.valid?
    assert sl.errors.invalid?(:interval)
    sl.interval = 3
    sl.valid?
    assert !sl.errors.invalid?(:interval)    
  end

  def test_remove_when_there_is_no_ledger_scheduled
    s = create_schedule
    schedule_id = s.id
    assert s.valid?
    count =  Ledger.count
    for i in 1..10 do
      l = create_ledger
      s.ledgers << l
    end
    assert_equal count + 10, count + s.ledgers.length
    Ledger.destroy_all
    assert_equal 0, Ledger.count
    assert_raise(ActiveRecord::RecordNotFound){ ScheduleLedger.find(schedule_id)}
  end

  def test_pending_legers
    s = create_schedule
    assert s.valid?
    count =  Ledger.count
    for i in 1..5 do
      l = create_ledger
      s.ledgers << l
    end
    for i in 1..5 do
      l = create_ledger
      l.done!
      l.save
      s.ledgers << l
    end
    assert_equal 5, s.pending_ledgers.length
  end

end
