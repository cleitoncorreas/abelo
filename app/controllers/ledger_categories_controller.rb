class LedgerCategoriesController < ApplicationController

  auto_complete_for :category, :name

  needs_organization

  uses_financial_tabs

  def autocomplete_category_name
    escaped_string = Regexp.escape(params[:category][:name])
    re = Regexp.new(escaped_string, "i")
    @categories = @organization.ledger_categories.select { |lc| lc.name.match re}
    render :layout=>false
  end

  def index
    redirect_to :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  post_only [ :create, :update, :autocomplete_name ]

  def list
    @categories = @organization.ledger_categories.paginate(:per_page => 10,:page => params[:page] )
  end

  def show
    @category = LedgerCategory.find(params[:id])
  end

  def new
    @category = LedgerCategory.new
    @periodicities = @organization.periodicities
  end

  def create
    @category = LedgerCategory.new(params[:category])
    @category.organization = @organization

    if @category.save
      flash[:notice] = t(:ledger_category_was_successfully_created)
      redirect_to :action => 'list'
    else
      @periodicities = @organization.periodicities
      render :action => 'new'
    end
  end

  def edit
    @category = @organization.ledger_categories.find(params[:id])
    @periodicities = @organization.periodicities
  end

  def update
    @category = @organization.ledger_categories.find(params[:id])

    if @category.update_attributes(params[:category])
      flash[:notice] = t(:ledger_category_was_successfully_updated)
      redirect_to :action => 'list'
    else
      @periodicities = @organization.periodicities
      render :action => 'edit'
    end

  end

  def destroy
    if @organization.ledger_categories.find(params[:id]).destroy
      redirect_to :action => 'list'
    else
      flash[:notice] = t(:the_ledger_category_cannot_be_destroy_with_ledgers_associated_to_its)
      redirect_to :action => 'list'
    end
  end

end
