class StockInController < ApplicationController

  needs_organization
  uses_stock_tabs

  def index
    redirect_to :action => 'list'
  end

  def list
    @query = params[:query]
    @query ||= params[:invoice][:number] if params[:invoice]
    
    if @query.nil?
      @invoices = @organization.invoices
      @invoice_pages, @invoices = paginate_by_collection @invoices
    else
      @invoices = @organization.invoices.full_text_search(@query)
      @invoice_pages, @invoices = paginate_by_collection @invoices
    end
  end

  def new
    @invoice = Invoice.new(:issue_date => Date.today)
    @suppliers = @organization.suppliers
  end

  def create
    @invoice = Invoice.new(params[:invoice])
    @invoice.organization = @organization
    if @invoice.save
      redirect_to :action => 'edit', :id => @invoice
    else
      @suppliers = @organization.suppliers
      @products = @organization.products
      @stock = StockIn.new
      @stocks = []
      render :action => 'new'
    end
  end

  def edit
    @invoice = @organization.invoices.find(params[:id])
    @suppliers = @organization.suppliers
    @products = @organization.products
    @stocks = @invoice.stock_ins
    @stock = StockIn.new(:price => 0, :amount => 1)
    @ledgers = @invoice.ledgers
    @ledger = Ledger.new_ledger(:date => Date.today)
    @ledger_categories =  @organization.stock_ledger_categories_by_payment_method(@ledger.payment_method)
  end

  def update
    @invoice = @organization.invoices.find(params[:id])
    if @invoice.update_attributes(params[:invoice])
        redirect_to :action => 'list'
    else
      @suppliers = @organization.suppliers
      @products = @organization.products
      @stock = StockIn.new(:validity => Date.today)
      render :action => 'new'
    end
  end

  def show
    @invoice = @organization.invoices.find(params[:id])
    @stocks = @invoice.stock_ins
  end

  def destroy
    @invoice = @organization.invoices.find(params[:id])
    @invoice.destroy
    redirect_to :action => 'list'
  end

  ###################################
  # Invoice Item Actions
  ###################################
 
  # Add a new stock item to the invoice
  def add_item
    @invoice = @organization.invoices.find(params[:id])
    @stock = StockIn.new(params[:stock])
    @stock.invoice = @invoice
    if @stock.save
      @stock = StockIn.new(:price => 0, :amount => 1)
    end
    @suppliers = @organization.suppliers
    @products = @organization.products
    @stocks = @invoice.stock_ins
    render :partial => 'invoice_new_items'
  end

  # Edit a stock item to the invoice
  def edit_item
    @invoice = @organization.invoices.find(params[:id])
    @stock = @invoice.stock_ins.find(params[:stock_id])
    @products = @organization.products
    @stocks = @invoice.stock_ins.reject{|s| s == @stock}
    render :partial => 'invoice_edit_items'
  end

  # Save the changes of a stock item
  def update_item
    @products = @organization.products
    @invoice = @organization.invoices.find(params[:id])
    @stock = @invoice.stock_ins.find(params[:stock_id])
    @stocks = @invoice.stock_ins
    if @stock.update_attributes(params[:stock])
      @stock = StockIn.new(:price => 0, :amount => 1)
      render :partial => 'invoice_new_items'
    else
      render :partial => 'invoice_edit_items'
    end
  end

  ###################################
  # Payment methods
  ###################################

  # Details the payment method
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
    render :partial => 'new_payment'
  end

  def edit_payment
    @invoice = @organization.invoices.find(params[:id])
    @ledger = @organization.ledgers(params[:ledger_id])
    @banks = Bank.find(:all)
    @ledgers = @invoice.ledgers.reject{|l| l == @ledger}
    @ledger_categories =  @organization.stock_ledger_categories_by_payment_method(@ledger.payment_method)
    render :partial => 'edit_payment'
  end

  def update_payment
    @invoice = @organization.invoices.find(params[:id])
    @ledger = @organization.ledgers(params[:ledger_id])
    @ledgers = @invoice.ledgers
    if @ledger.update_attributes(params[:ledger])
      @ledger = Ledger.new_ledger(:date => Date.today)
      @ledger_categories =  @organization.stock_ledger_categories_by_payment_method(@ledger.payment_method)
      render :partial => 'new_payment'
    else
      @ledger_categories =  @organization.stock_ledger_categories_by_payment_method(@ledger.payment_method)
      render :partial => 'edit_payment'
    end
  end

end
