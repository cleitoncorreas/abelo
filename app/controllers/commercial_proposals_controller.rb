class CommercialProposalsController < ApplicationController

  needs_organization

  def index
    redirect_to :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @commercial_proposals_templates = @organization.commercial_proposals_templates
    @commercial_proposals = @organization.commercial_proposals_not_templates
  end

  def show
    @commercial_proposal = CommercialProposal.find(params[:id])
  end

  def new
    @commercial_proposal = CommercialProposal.new
    @departments = @organization.departments
  end

  def create
    @commercial_proposal = CommercialProposal.new(params[:commercial_proposal])
    @commercial_proposal.organization = @organization
    if @commercial_proposal.save
      flash[:notice] = _('The commercial proposal was successfully created.')
      redirect_to :action => 'list'
    else
      @departments = @organization.departments
      render :action => 'new'
    end
  end

  def edit
    @commercial_proposal = CommercialProposal.find(params[:id])
    @departments = @organization.departments
  end

  def update
    @commercial_proposal = CommercialProposal.find(params[:id])
    if @commercial_proposal.update_attributes(params[:commercial_proposal])
      flash[:notice] = 'CommercialProposal was successfully updated.'
      redirect_to :action => 'show', :id => @commercial_proposal
    else
      @departments = @organization.departments
      render :action => 'edit'
    end
  end

  def destroy
    CommercialProposal.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

  def choose_template
    @templates = @organization.commercial_proposals_templates
  end

  def new_from_template
    @commercial_proposal = CommercialProposal.find(params[:id]).clone
    @commercial_proposal.name = ''
    @commercial_proposal.departments.clear
    @commercial_proposal.is_template = false
    @departments = @organization.departments
    render :action => 'new'
  end

end
