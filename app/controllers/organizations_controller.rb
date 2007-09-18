class OrganizationsController < ApplicationController

  needs_administrator

  before_filter :create_admin_organization_tabs

  def index
    redirect_to :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @organization_pages, @organizations = paginate :organizations, :per_page => 10
  end

  def show
    @organization = Organization.find(params[:id])
  end

  def new
    @organization = Organization.new
  end

  def create
    @organization = Organization.new(params[:organization])
    if @organization.save
      flash[:notice] = _('Organization was successfully created.')
      redirect_to :action => 'edit_configuration', :id => @organization
    else
      render :action => 'new'
    end
  end

  def edit
    @organization = Organization.find(params[:id])
  end

  def update
    @organization = Organization.find(params[:id])
    if @organization.update_attributes(params[:organization])
      flash[:notice] = _('The organization was successfully updated.')
      redirect_to :action => 'show', :id => @organization
    else
      render :action => 'edit'
    end
  end

  def destroy
    Organization.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

  def list_configuration
    @configurations = Configuration.models
  end

  def new_configuration
    @configuration = Configuration.new
    @product_informations = Product.column_names
  end

  def create_configuration
    @configuration = Configuration.new(params[:configuration])
    @configuration.is_model = true
    @configuration.full_product = params[:product_full_informations].nil? ? Array.new : params[:product_full_informations].keys
    @configuration.lite_product = params[:product_lite_informations].nil? ? Array.new : params[:product_lite_informations].keys

    if @configuration.save
      flash[:notice] = _('The configurations was successfully updated.')
      redirect_to :action => 'list_configuration'
    else
      render :action => 'new'
    end
  end

  def show_configuration
    @organization = Organization.find(params[:id])
    @configuration = @organization.configuration
    @ledger_display = @configuration.ledger_display_fields
    @ledger_display_in_list = @configuration.ledger_display_fields_in_list
    @product_display = @configuration.product_display_fields
    @product_display_in_list = @configuration.product_display_fields_in_list
    @supplier_display = @configuration.supplier_display_fields
    @supplier_display_in_list = @configuration.supplier_display_fields_in_list
    @worker_display = @configuration.worker_display_fields
    @worker_display_in_list = @configuration.worker_display_fields_in_list
  end

  def edit_configuration
    @organization = Organization.find(params[:id])
    @configuration = @organization.configuration
    
    @ledger_informations = LedgerDisplay.available_fields
    @ledger_display = @configuration.ledger_display_fields
    @ledger_display_in_list = @configuration.ledger_display_fields_in_list

    @product_informations = ProductDisplay.available_fields
    @product_display = @configuration.product_display_fields
    @product_display_in_list = @configuration.product_display_fields_in_list

    @worker_informations = WorkerDisplay.available_fields
    @worker_display = @configuration.worker_display_fields
    @worker_display_in_list = @configuration.worker_display_fields_in_list

    @supplier_informations = SupplierDisplay.available_fields
    @supplier_display = @configuration.supplier_display_fields
    @supplier_display_in_list = @configuration.supplier_display_fields_in_list
  end

  def update_configuration
    @configuration = Configuration.find(params[:id])
    @organization = @configuration.organization
    @configuration.product_display_fields = params[:product_display_configurations].nil? ? Array.new : params[:product_display_configurations].keys
    @configuration.product_display_fields_in_list = params[:product_display_configurations_in_list].nil? ? Array.new : params[:product_display_configurations_in_list].keys

    if @configuration.update_attributes(params[:configuration])
      flash[:notice] = _('The configurations was successfully updated.')
      redirect_to :action => 'show_configuration', :id => @organization.id
    else
      render :action => 'edit'
    end
  end
end
