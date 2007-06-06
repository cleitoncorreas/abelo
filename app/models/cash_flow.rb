class CashFlow < ActiveRecord::Base
  belongs_to :historical
  belongs_to :organization
  belongs_to :specification

  def add_stock_entry(entry_id)
    entry = StockIn.find(entry_id)
    self.date = entry.date
    self.value = entry.price

    h = Historical.new
    h.name = "stock entry of #{entry.product.description}"
    h.type_of = TypeTransaction::DEBIT
    h.operational = true
    h.organization = entry.organization
    h.save
    self.historical = h
   
    s = Specification.new
    s.name = entry.supplier.name
    s.organization = entry.organization
    s.save
    self.specification = s

    self.organization = entry.organization
    if entry.payment_status == true
      self.foreseen = true
    end
    self.save
  end

  def add_sale(sale_id)
    sale= Sale.find(sale_id)
    self.date = sale.date
    self.value = sale.total_value

    h = Historical.new
    h.name = "sale #{sale.id}"
    h.type_of = TypeTransaction::CREDIT
    h.operational = true
    h.organization = sale.organization
    h.save
    self.historical = h
   
    s = Specification.new
    if sale.customer.nil?
      s.name = 'customer not identified'
    else  
      s.name = sale.customer.name
    end
    s.organization = sale.organization
    s.save
    self.specification = s

    self.organization = sale.organization
    self.save
   
  end

  def CashFlow.total_value(cash_flows, foreseen_value)
    value = 0.0
    if cash_flows
      cash_flows.each { |c|
        if c.foreseen == foreseen_value
          value = value + c.value
	end
      }
    end
    return value
  end

  def CashFlow.month_total_value(month, cash_flows, foreseen_value)
    total = 0.0
    if cash_flows
      cash_flows.each { |c|
        if (c.date.month == month) and (c.foreseen == foreseen_value)
          total += c.value
        end
      }
    end
    return total
  end


end
