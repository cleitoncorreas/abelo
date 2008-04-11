class MassMailsController < ApplicationController

  auto_complete_for :mass_mail, :subject

  needs_organization

  uses_mass_mails_tabs

  def autocomplete_subject
    escaped_string = Regexp.escape(params[:mass_mail][:subject])
    re = Regexp.new(escaped_string, "i")
    @mass_mails = @organization.mass_mails.select { |mm| mm.subject.match re}
    render :layout=>false
  end

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @query = params[:query]
    @query ||= params[:mass_mail][:subject] if params[:mass_mail]

    if @query.nil?
      @mass_mails = @organization.mass_mails
      @mass_mail_pages, @mass_mails = paginate_by_collection @mass_mails
    else
      @mass_mails = @organization.mass_mails.full_text_search(@query)
      @mass_mail_pages, @mass_mails = paginate_by_collection @mass_mails
    end

  end

  def show
    @mass_mail = @organization.mass_mails.find(params[:id])
  end

  def new
    @mass_mail = MassMail.new
    @mass_mail.organization = @organization
  end

  def create
    @mass_mail = MassMail.new(params[:mass_mail])
    @mass_mail.organization = @organization
    if @mass_mail.save
      flash[:notice] = 'MassMail was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @mass_mail = @organization.mass_mails.find(params[:id])
  end

  def update
    @mass_mail = MassMail.find(params[:id])

    if @mass_mail.update_attributes(params[:mass_mail])
      flash[:notice] = 'MassMail was successfully updated.'
      render :action => 'list'
    else
      render :action => 'edit'
    end
  end

  def destroy
    @organization.mass_mails.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

  def filter_categories
    @mass_mail = @organization.mass_mails.find(params[:id])
  end

  def filter_customers
    @mass_mail_id = params[:id]
    @customers = []
    list_categories = params[:categories]
    list_products = params[:products]
    if list_categories and not list_products
      list_categories = list_categories.keys
      @customers.concat(@organization.customers_by_categories(list_categories))
      @customers = @customers.uniq
    elsif list_products and not list_categories
      list_products = list_products.keys
      @customers.concat(@organization.customers_by_products(list_products))
      @customers = @customers.uniq
    elsif list_products and list_categories
      customers_1 = []
      customers_2 = []
      list_categories = list_categories.keys
      list_products = list_products.keys
      customers_1.concat(@organization.customers_by_categories(list_categories))
      customers_2.concat(@organization.customers_by_products(list_products))
      @customers = customers_1 & customers_2
    end  
  end

  def send_emails
    @mass_mail = @organization.mass_mails.find(params[:id])
    @emails = []
    lista = params[:customers]
    if lista
      lista.keys.each { |k|
        @emails.push(@organization.customers.find(k).email)
      }
      DirectMail::deliver_mail_to(@emails, @mass_mail)
      render :partial => "message", :layout => true
    end
  end

end
