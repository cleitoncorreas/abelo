class UnitsController < ApplicationController

  needs_organization

  uses_configurations_tabs

  def autocomplete_unit_name
    escaped_string = Regexp.escape(params[:unit][:name])
    re = Regexp.new(escaped_string, "i")
    @units = @organization.unit_measures.select { |pr| pr.name.match re}
    render :layout=>false
  end

  # Show all units
  def index
    redirect_to :action => 'list'
  end

  def list
    @query = params[:query]
    @query ||= params[:unit][:name] if params[:unit]

    if @query.nil?
      @units = @organization.unit_measures.paginate(:per_page => 10,:page => params[:page] )
    else
      @units = @organization.unit_measures.full_text_search(@query).paginate(:per_page => 10,:page => params[:page] )
    end
  end

  def show
    @unit = @organization.unit_measures.find(params[:id])
  end

  def new
    @unit = UnitMeasure.new
  end

  def create
    @unit = UnitMeasure.new(params[:unit])
    @unit.organization = @organization
    if @unit.save
      flash[:notice] = t(:the_unit_was_successfully_created)
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @unit = @organization.unit_measures.find(params[:id])
  end

  def update
    @unit = @organization.unit_measures.find(params[:id])

    if @unit.update_attributes(params[:unit])
      flash[:notice] = t(:the_unit_was_successfully_updated)
      redirect_to :action => 'list'
    else
      render :action => 'edit'
    end
  end

  def destroy
    @organization.unit_measures.find(params[:id]).destroy
    redirect_to :action => 'list'
  end


end
