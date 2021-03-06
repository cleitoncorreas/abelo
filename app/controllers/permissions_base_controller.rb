class PermissionsBaseController < ApplicationController

  uses_popup_plugin

  def autocomplete_user_login
    @organization ||= Organization.find(params[:organization_id])
    escaped_string = Regexp.escape(params[:user][:login])
    re = Regexp.new(escaped_string, "i")
    @users = @organization.users.select { |u| u.login.match re}
    render :template => 'permissions_base/autocomplete_user_login', :layout => false
  end

  def index
    list
  end

  verify :method => :post, :only => [ :destroy, :create_with_template, :update_template ], 
         :redirect_to => { :action => :list }

  def list
    @organization ||= Organization.find(params[:organization_id])
    @query = params[:query]
    @query ||= params[:user][:login] if params[:user]


    if @query.nil?
      @users = @organization.users
      @users.map{|u| u.profile_organization = @organization }
      @users = @users.paginate(:per_page => 10,:page => params[:page] )
    else
      @users = @organization.users.full_text_search(@query)
      @users.map{|u| u.profile_organization = @organization }
      @users = @users.paginate(:per_page => 10,:page => params[:page] )
    end

    render :template => 'permissions_base/list'
  end

  def new
    @organization ||= Organization.find(params[:organization_id])
    @user = params[:id].nil? ? User.new : User.find(params[:id])
    render :template => 'permissions_base/new' 
  end

  def create
    @organization ||= Organization.find(params[:organization_id])
    @user = params[:id].nil? ? User.new : User.find(params[:id])
    @user.validates_profile = true

    template = params[:user][:template] unless params[:user].nil?
    @user.profile_organization = @organization

    if Profile.locations_by_template(template)
      @user.template_valid = true
    end
    
    if @user.update_attributes(params[:user])
      flash[:notice] = t(:user_successfully_created)
      redirect_to :action => 'list', :organization_id => @organization
    else
      render :template => 'permissions_base/new'
    end
  end

  def edit
    @organization ||= Organization.find(params[:organization_id])
    @user = @organization.users.find(params[:id])
    @user.profile_organization= @organization
    render :template => 'permissions_base/edit'
  end

  def update
    @organization ||= Organization.find(params[:organization_id])
    @user = @organization.users.find(params[:id])
    @user.validates_profile = true

    template = params[:user][:template] unless params[:user].nil?
    if Profile.locations_by_template(template)
      @user.template_valid = true
    end
    
    @user.profile_organization = @organization
    if @user.update_attributes(params[:user])
      flash[:notice] = t(:user_was_successfully_upated)
      redirect_to :action => 'list', :organization_id => @organization
    else
      render :template => 'permissions_base/edit'
    end
    
  end

  def show
    @organization ||= Organization.find(params[:organization_id])
    @user = @organization.users.find(params[:id])
    @user.profile_organization = @organization
    render :template => 'permissions_base/show'
  end

  def destroy
    @organization ||= Organization.find(params[:organization_id])
    @organization.users.find(params[:id]).destroy    
    redirect_to :action => 'list', :organization_id => @organization
  end

  def popup_user
    @organization ||= Organization.find(params[:organization_id])
    render :template => 'permissions_base/popup_user', :layout => false
  end

  def search_user
    @organization ||= Organization.find(params[:organization_id])
    str = params[:search].blank? ? '*' : params[:search]
    @users = User.full_text_search(str)
    @users.delete(current_user)
    render :template => 'permissions_base/search_user', :layout => false
  end

end
