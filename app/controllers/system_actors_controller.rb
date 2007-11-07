class SystemActorsController < ApplicationController

  auto_complete_for :system_actor, :name

  needs_organization

  uses_register_tabs

  SYSTEM_ACTORS = {
    'customer' => _('Customer'),
    'worker' => _('Workers'),
    'supplier' => _('Supplier'),
  }

  def autocomplete_name
    actor = params[:actor].camelize
    escaped_string = Regexp.escape(params[:system_actor][:name])
    re = Regexp.new(escaped_string, "i")
    @system_actors = SystemActor.find(:all, :conditions => [ "type = ?", actor ]).select { |sa| sa.name.match re}
    render :layout=>false
  end

  def index
    redirect_to :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @actor = params[:actor] ||= 'worker'
      
    @query = params[:query]
    @query ||= params[:system_actor][:name] if params[:system_actor]

    if @query.nil?
      @system_actors = @organization.system_actors.find(:all, :conditions => ["type = ?", @actor.camelize])
      @system_actor_pages, @system_actors = paginate_by_collection @system_actors
    else
      @system_actors = @actor.camelize.constantize.full_text_search(@query)
      @system_actor_pages, @system_actors = paginate_by_collection @system_actors
    end
  end

  def show
    check_actor_presence
    @system_actor = @organization.system_actors.find(params[:id])
    @ledger_sales = @system_actor.ledgers_by_sales
  end

  def show_ledgers
    check_actor_presence
    @system_actor = @organization.system_actors.find(params[:id])
    @ledger_sales = @system_actor.ledgers_by_sales
  end

  def show_documents
    check_actor_presence
    @system_actor = @organization.system_actors.find(params[:id])
    @documents = @system_actor.documents
  end

  def new
    check_actor_presence
    @system_actor =  @actor.camelize.constantize.new() 
    @system_actor.organization = @organization
  end

  def create
    check_actor_presence

    @system_actor = @actor.camelize.constantize.new(params[:system_actor])
    @system_actor.organization = @organization
    if @system_actor.save
      flash[:notice] = _('%s was successfully created.') % @actor
      redirect_to :action => 'list', :actor => @actor
    else
      render :action => 'new'
    end
  end

  def edit
   check_actor_presence
    @system_actor = @organization.send("#{@actor.pluralize}").find(params[:id])
  end

  def update
    check_actor_presence

    @system_actor = @organization.send("#{@actor.pluralize}").find(params[:id])

    if @system_actor.update_attributes(params[:system_actor])
      flash[:notice] = _('%s was successfully updated.') % SystemActor.describe(@actor)
      redirect_to :action => 'list', :actor => @actor
    else
      render :action => 'edit'
    end
  end

  def destroy
    check_actor_presence

    @system_actor = @organization.send("#{@actor.pluralize}").find(params[:id])
    @system_actor.destroy
    redirect_to :action => 'list', :actor => @actor 
  end

  def get_person_type
    check_actor_presence
    @system_actor =  @actor.camelize.constantize.new(params[:system_actor])
    if params[:value] == 'juristic'
      render :partial => 'juristic_person'
    else
      render :partial => 'natural_person'
    end
  end

  def check_actor_presence
    @actor = params[:actor]
    begin
      @actor.camelize.constantize
    rescue
      render_error(_("This actor it's not valid"))
      return
    end
  end

end
