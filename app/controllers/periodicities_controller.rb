class PeriodicitiesController < ApplicationController

  auto_complete_for :periodicity, :name

  needs_organization

  def autocomplete_name
    escaped_string = Regexp.escape(params[:periodicity][:name])
    re = Regexp.new(escaped_string, "i")
    @periodicities = @organization.periodicities.select { |dp| dp.name.match re}
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
    @query ||= params[:periodicity][:name] if params[:periodicity]

    if @query.nil?
      @periodicities  = @organization.periodicities
      @periodicity_pages, @periodicities = paginate_by_collection @periodicities 
    else
      @periodicities = @organization.periodicities.full_text_search(@query)
      @periodicity_pages, @periodicities = paginate_by_collection @periodicities 
    end

  end

  def show
    @periodicity = Periodicity.find(params[:id])
  end

  def new
    @periodicity = Periodicity.new
  end

  def create
    @periodicity = Periodicity.new(params[:periodicity])
    @periodicity.organization = @organization
    if @periodicity.save
      flash[:notice] = 'Periodicity was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @periodicity = Periodicity.find(params[:id])
  end

  def update
    @periodicity = Periodicity.find(params[:id])
    if @periodicity.update_attributes(params[:periodicity])
      flash[:notice] = 'Periodicity was successfully updated.'
      redirect_to :action => 'show', :id => @periodicity
    else
      render :action => 'edit'
    end
  end

  def destroy
    Periodicity.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
