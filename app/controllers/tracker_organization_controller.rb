class TrackerOrganizationController < ApplicationController

  needs_organization

  uses_tracker_organization_tabs

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @tracker = @organization.tracker
  end

  def draw
    tracker = @organization.tracker
    g = Gruff::SideStackedBar.new('700x100')
    g.theme_pastel
    g.hide_legend = true
    g.hide_title = true
    g.minimum_value = 0
    g.maximum_value = tracker.available_points

    g.marker_font_size=18
    g.has_left_labels=true
    g.data(_("Used Points"), tracker.total_points)
    g.labels = {0 => _('Used Points')}

    send_data(g.to_blob,
      :disposition => 'inline',
      :type => 'image/png',
      :filename => "rail.png")
  end

end
