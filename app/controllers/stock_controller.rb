class StockController < ApplicationController

  helper StockHelper

  require 'payment/payment_actions'
  include PaymentActions

  needs_organization
    
  uses_stock_tabs

  def autocomplete_product_name
    escaped_string = Regexp.escape(params[:product][:name])
    re = Regexp.new(escaped_string, "i")
    @products = @organization.products.select{|p| p.name.match re}
    render :template => 'stock_base/autocomplete_product_name', :layout=>false
  end

  def payment_object 
    @organization.invoices.find(params[:id])
  end

  def index
    redirect_to :action => 'list'
  end

  def list
    @query = params[:query]
    @query ||= params[:product][:name] if params[:product]

    @stocks = @organization.stock_virtuals(@query).paginate(:per_page => 10,:page => params[:page] )
    render :template => 'stock_base/list'
  end

  def new
    if params[:product_id].blank?
      redirect_to :controller => 'stock_buy', :action => 'new'
    else
      redirect_to :action => 'add', :product_id => params[:product_id]
    end
  end

  def add
    product = @organization.products.find(params[:product_id])
    @stock = StockBuy.new(:product => product, :amount => 1)
    @invoice = Invoice.new(:issue_date => DateTime.now)
    @suppliers = @organization.suppliers
  end

  def create
    product = @organization.products.find(params[:product_id])
    @stock = StockBuy.new(params[:stock])
    @stock.product = product
    @invoice = params[:invoice_id].blank? ? Invoice.new(params[:invoice]) : @organization.invoices.find(params[:invoice_id])
    @stock.invoice = @invoice
    
    if @invoice.save and @invoice.stock_buys << @stock
      flash.now[:notice] = t(:it_was_successfully_created)
      redirect_to :action => 'edit', :invoice_id => @invoice,  :stock_id => @stock
    else
      @suppliers = product.suppliers
      render :action => 'add'
    end
  end

  def edit
    @invoice = @organization.invoices.find(params[:invoice_id])
    @stock = @invoice.stock_buys.find(params[:stock_id])
    @payment_object = @invoice
    @suppliers = @organization.suppliers
    @ledgers = @invoice.ledgers 
    @ledger = Ledger.new(:date => Date.today)
    @banks = Bank.find(:all)
    @ledger_categories =  @organization.stock_ledger_categories_by_payment_method(@ledger.payment_method)
  end

  def update
    @invoice = @organization.invoices.find(params[:invoice_id])
    @stock = @invoice.stock_buys.find(params[:stock_id])

    if @invoice.update_attributes(params[:invoice]) and @stock.update_attributes(params[:stock])
      redirect_to :action => 'history', :product_id => @stock.product
    else
      @payment_object = @invoice
      @suppliers = @organization.suppliers
      @ledgers = @invoice.ledgers 
      @ledger = Ledger.new(:date => Date.today)
      @banks = Bank.find(:all)
      @ledger_categories =  @organization.stock_ledger_categories_by_payment_method(@ledger.payment_method)
      render :action => 'edit'
    end
  end


  def history
    @product = @organization.products.find(params[:product_id])
    @stocks = @product.stocks
    render :template => 'stock_base/history'
  end

end
