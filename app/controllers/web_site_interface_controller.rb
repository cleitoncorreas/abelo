class WebSiteInterfaceController < ApplicationController

  needs_environment

  uses_web_site_tabs

  design_editor :content_holder => 'environment', :interface_holder => 'organization', :autosave => true, :block_types => :block_types

  def index
    redirect_to :action => 'design_editor'
  end

   def block_types
    %w[
       FavoriteLinksWebSite
     ] 
  end

end