# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base

  HTTP_FORCE_ERROR = 409
  include AuthenticatedSystem
  include AccessControl
  helper AccessControl
  before_filter :login_required
  before_filter :check_access_control
  def check_access_control
    unless can(params[:action])
      render_access_denied_screen
    end
  end
  def check_admin_rights
    unless current_user.administrator
      render_access_denied_screen
    end
  end

  before_filter :i18n_settings
  def i18n_settings
    headers['Content-Type'] = 'text/html; charset=utf-8'
  end

  def self.needs_organization
    before_filter :load_organization
    layout 'organization'
  end

  def load_organization
    @organization = Organization.find_by_nickname(params[:organization_nickname])
    render :text => _('There is no organization with nickname %s') % params[:organization_nickname] unless @organization
  end

  def render_access_denied_screen
    render :template => 'users/access_denied', :status => 403, :layout => false
  end

  def render_error(message = nil)
    @message = message.nil? ? _('Access error') : message
    render :template => 'shared/access_error'
  end

  def clean
    render_for :clean 
  end
  
  protected
  def render_for(action = :save, type = :success, html_id = nil)
    if (action == :save && type == :success)
      render :update do |page|
        page.replace_html 'list', :partial => 'list'
        page.replace_html 'action', ''
      end
      
    elsif (action == :destroy)
      render :update do |page|
        page.remove html_id
      end      
      
    elsif(action == :save || action == :clean)
      render :update do |page|
        page.replace_html 'form', :partial => 'form'
      end
      
    else
      render :update do |page|
        page.replace_html 'list', :partial => 'list'
      end     
    end
    
  end

end
