module InvoicePayment

  def payment_details
    @invoice = @organization.invoices.find(params[:id])
    payment_method = params[:payment_method]
    if !payment_method.blank?
      @ledger = params[:ledger_id].blank? ? Ledger.new_ledger(:payment_method => payment_method) : @organization.ledgers.find(params[:ledger_id])
      @banks = Bank.find(:all)
      @hide_sign = true
      @ledger_categories =  @organization.stock_ledger_categories_by_payment_method(@ledger.payment_method)
      @ledgers = @invoice.ledgers
      render :partial => 'shared_payments/payment_details'
    else
      render :nothing => true
    end
  end

  def edit_payment
    @invoice = @organization.invoices.find(params[:id])
    @ledger = @organization.ledgers(params[:ledger_id])
    @banks = Bank.find(:all)
    @ledgers = @invoice.ledgers.reject{|l| l == @ledger}
    @ledger_categories =  @organization.stock_ledger_categories_by_payment_method(@ledger.payment_method)
    render :partial => 'shared_payments/edit_payment'
  end

  def add_payment
    @invoice = @organization.invoices.find(params[:id])
    @ledger = Ledger.new_ledger(params[:ledger])
    @ledger.owner = @invoice
    @ledger.bank_account = @organization.default_bank_account
    @banks = Bank.find(:all)
    if @ledger.save
      @ledger = Ledger.new_ledger(:date => Date.today)
    end
    @ledgers = @invoice.ledgers
    @ledger_categories =  @organization.stock_ledger_categories_by_payment_method(@ledger.payment_method)
    render :partial => 'shared_payments/new_payment'
  end

  def update_payment
    @invoice = @organization.invoices.find(params[:id])
    @ledger = @organization.ledgers(params[:ledger_id])
    @ledgers = @invoice.ledgers
    if @ledger.update_attributes(params[:ledger])
      @ledger = Ledger.new_ledger(:date => Date.today)
      @ledger_categories =  @organization.stock_ledger_categories_by_payment_method(@ledger.payment_method)
      render :partial => 'shared_payments/new_payment'
    else
      @ledger_categories =  @organization.stock_ledger_categories_by_payment_method(@ledger.payment_method)
      render :partial => 'shared_payments/edit_payment'
    end
  end


end
