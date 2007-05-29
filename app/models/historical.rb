class Historical < ActiveRecord::Base
  has_many :cash_flows

  def cash_flows_for_day(date)
    return self.cash_flows.find(:all, :conditions => "date = '#{date}'" )
  end

  def cash_flows_for_month(month)
    cash_flows_for_period('month', month)
  end

  def cash_flows_for_year(year)
    cash_flows_for_period('year', year)
  end

  
  private

  def cash_flows_for_period(period, value)
    cash_flows = Array.new
    self.cash_flows.each {|c|
      if c.date.send("#{period}") == value
        cash_flows.push(c)
      end
    }
    return cash_flows
  end
end
