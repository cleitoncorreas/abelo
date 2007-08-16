# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  ACTIONS = %w[
    'new' => _('New')
    'edit' => _('Edit') 
    'remove' => _('Remove') 
  ]

  def button(button, title, type, url_options = {}, html_options = {})
    html_options[:class] ||= "button button_#{type}"
    html_options[:title] ||= title
    if [:save, :search ].include? type
      design_display_icon_submit button, title , html_options
    else
      design_display_icon(button, title, url_options, html_options)
    end
  end

  def button_remote(button, title, type, url_options = {}, html_options = {})
    local_html_options = html_options.merge({ :class => "button button_#{type}" })
    design_display_icon(button, title, url_options, local_html_options, true)
  end

  # Creates a color picker field.
  #
  # Slightly based on http://www.bigbold.com/snippets/posts/show/2084
  # Color HEX/names from http://www.w3schools.com/html/html_colornames.asp
  #
  # TODO: chose a smaller ser of colors
  def color_select(object, method)
    colors = [
      [ nil,  _('N/A') ],
      [ '#F0F8FF',  _('Alice Blue') ],
      [ '#FAEBD7',  _('Antique White') ],
      [ '#00FFFF',  _('Aqua') ],
      [ '#7FFFD4',  _('Aquamarine') ],
      [ '#F0FFFF',  _('Azure') ],
      [ '#F5F5DC',  _('Beige') ],
      [ '#FFE4C4',  _('Bisque') ],
      [ '#000000',  _('Black') ],
      [ '#FFEBCD',  _('Blanched Almond') ],
      [ '#0000FF',  _('Blue') ],
      [ '#8A2BE2',  _('Blue Violet') ],
      [ '#A52A2A',  _('Brown') ],
      [ '#DEB887',  _('Burly Wood') ],
      [ '#5F9EA0',  _('Cadet Blue') ],
      [ '#7FFF00',  _('Chartreuse') ],
      [ '#D2691E',  _('Chocolate') ],
      [ '#FF7F50',  _('Coral') ],
      [ '#6495ED',  _('Cornflower Blue') ],
      [ '#FFF8DC',  _('Cornsilk') ],
      [ '#DC143C',  _('Crimson') ],
      [ '#00FFFF',  _('Cyan') ],
      [ '#00008B',  _('Dark Blue') ],
      [ '#008B8B',  _('Dark Cyan') ],
      [ '#B8860B',  _('Dark Golden Rod') ],
      [ '#A9A9A9',  _('Dark Gray') ],
      [ '#A9A9A9',  _('Dark Grey') ],
      [ '#006400',  _('Dark Green') ],
      [ '#BDB76B',  _('Dark Khaki') ],
      [ '#8B008B',  _('Dark Magenta') ],
      [ '#556B2F',  _('Dark Olive Green') ],
      [ '#FF8C00',  _('Darkorange') ],
      [ '#9932CC',  _('Dark Orchid') ],
      [ '#8B0000',  _('Dark Red') ],
      [ '#E9967A',  _('Dark Salmon') ],
      [ '#8FBC8F',  _('Dark Sea Green') ],
      [ '#483D8B',  _('Dark Slate Blue') ],
      [ '#2F4F4F',  _('Dark Slate Gray') ],
      [ '#2F4F4F',  _('Dark Slate Grey') ],
      [ '#00CED1',  _('Dark Turquoise') ],
      [ '#9400D3',  _('Dark Violet') ],
      [ '#FF1493',  _('Deep Pink') ],
      [ '#00BFFF',  _('Deep Sky Blue') ],
      [ '#696969',  _('Dim Gray') ],
      [ '#696969',  _('Dim Grey') ],
      [ '#1E90FF',  _('Dodger Blue') ],
      [ '#B22222',  _('Fire Brick') ],
      [ '#FFFAF0',  _('Floral White') ],
      [ '#228B22',  _('Forest Green') ],
      [ '#FF00FF',  _('Fuchsia') ],
      [ '#DCDCDC',  _('Gainsboro') ],
      [ '#F8F8FF',  _('Ghost White') ],
      [ '#FFD700',  _('Gold') ],
      [ '#DAA520',  _('Golden Rod') ],
      [ '#808080',  _('Gray') ],
      [ '#808080',  _('Grey') ],
      [ '#008000',  _('Green') ],
      [ '#ADFF2F',  _('Green Yellow') ],
      [ '#F0FFF0',  _('Honey Dew') ],
      [ '#FF69B4',  _('Hot Pink') ],
      [ '#CD5C5C',  _('Indian Red') ],
      [ '#4B0082',  _('Indigo') ],
      [ '#FFFFF0',  _('Ivory') ],
      [ '#F0E68C',  _('Khaki') ],
      [ '#E6E6FA',  _('Lavender') ],
      [ '#FFF0F5',  _('Lavender Blush') ],
      [ '#7CFC00',  _('Lawn Green') ],
      [ '#FFFACD',  _('Lemon Chiffon') ],
      [ '#ADD8E6',  _('Light Blue') ],
      [ '#F08080',  _('Light Coral') ],
      [ '#E0FFFF',  _('Light Cyan') ],
      [ '#FAFAD2',  _('Light Golden Rod Yellow') ],
      [ '#D3D3D3',  _('Light Gray') ],
      [ '#D3D3D3',  _('Light Grey') ],
      [ '#90EE90',  _('Light Green') ],
      [ '#FFB6C1',  _('Light Pink') ],
      [ '#FFA07A',  _('Light Salmon') ],
      [ '#20B2AA',  _('Light Sea Green') ],
      [ '#87CEFA',  _('Light Sky Blue') ],
      [ '#778899',  _('Light Slate Gray') ],
      [ '#778899',  _('Light Slate Grey') ],
      [ '#B0C4DE',  _('Light Steel Blue') ],
      [ '#FFFFE0',  _('Light Yellow') ],
      [ '#00FF00',  _('Lime') ],
      [ '#32CD32',  _('Lime Green') ],
      [ '#FAF0E6',  _('Linen') ],
      [ '#FF00FF',  _('Magenta') ],
      [ '#800000',  _('Maroon') ],
      [ '#66CDAA',  _('Medium Aqua Marine') ],
      [ '#0000CD',  _('Medium Blue') ],
      [ '#BA55D3',  _('Medium Orchid') ],
      [ '#9370D8',  _('Medium Purple') ],
      [ '#3CB371',  _('Medium Sea Green') ],
      [ '#7B68EE',  _('Medium Slate Blue') ],
      [ '#00FA9A',  _('Medium Spring Green') ],
      [ '#48D1CC',  _('Medium Turquoise') ],
      [ '#C71585',  _('Medium Violet Red') ],
      [ '#191970',  _('Midnight Blue') ],
      [ '#F5FFFA',  _('Mint Cream') ],
      [ '#FFE4E1',  _('Misty Rose') ],
      [ '#FFE4B5',  _('Moccasin') ],
      [ '#FFDEAD',  _('Navajo White') ],
      [ '#000080',  _('Navy') ],
      [ '#FDF5E6',  _('Old Lace') ],
      [ '#808000',  _('Olive') ],
      [ '#6B8E23',  _('Olive Drab') ],
      [ '#FFA500',  _('Orange') ],
      [ '#FF4500',  _('Orange Red') ],
      [ '#DA70D6',  _('Orchid') ],
      [ '#EEE8AA',  _('Pale Golden Rod') ],
      [ '#98FB98',  _('Pale Green') ],
      [ '#AFEEEE',  _('Pale Turquoise') ],
      [ '#D87093',  _('Pale Violet Red') ],
      [ '#FFEFD5',  _('Papaya Whip') ],
      [ '#FFDAB9',  _('Peach Puff') ],
      [ '#CD853F',  _('Peru') ],
      [ '#FFC0CB',  _('Pink') ],
      [ '#DDA0DD',  _('Plum') ],
      [ '#B0E0E6',  _('Powder Blue') ],
      [ '#800080',  _('Purple') ],
      [ '#FF0000',  _('Red') ],
      [ '#BC8F8F',  _('Rosy Brown') ],
      [ '#4169E1',  _('Royal Blue') ],
      [ '#8B4513',  _('Saddle Brown') ],
      [ '#FA8072',  _('Salmon') ],
      [ '#F4A460',  _('Sandy Brown') ],
      [ '#2E8B57',  _('Sea Green') ],
      [ '#FFF5EE',  _('Sea Shell') ],
      [ '#A0522D',  _('Sienna') ],
      [ '#C0C0C0',  _('Silver') ],
      [ '#87CEEB',  _('Sky Blue') ],
      [ '#6A5ACD',  _('Slate Blue') ],
      [ '#708090',  _('Slate Gray') ],
      [ '#708090',  _('Slate Grey') ],
      [ '#FFFAFA',  _('Snow') ],
      [ '#00FF7F',  _('Spring Green') ],
      [ '#4682B4',  _('Steel Blue') ],
      [ '#D2B48C',  _('Tan') ],
      [ '#008080',  _('Teal') ],
      [ '#D8BFD8',  _('Thistle') ],
      [ '#FF6347',  _('Tomato') ],
      [ '#40E0D0',  _('Turquoise') ],
      [ '#EE82EE',  _('Violet') ],
      [ '#F5DEB3',  _('Wheat') ],
      [ '#FFFFFF',  _('White') ],
      [ '#F5F5F5',  _('White Smoke') ],
      [ '#FFFF00',  _('Yellow') ],
      [ '#9ACD32',  _('Yellow Green') ],
    ]

    value = self.instance_variable_get("@#{object}").send(method)
    select_tag(
      "#{object}[#{method}]",
      colors.map { |c|
        code, name = c
        selected = (code==value) ? 'selected' : ''
        "<option value=\"#{code}\" style=\"background: #{code}\" #{selected}>#{name}</option>" 
      }.join("\n"),
      :style => "background: #{value}", :id => "#{object}_#{method}"
    ) + observe_field("#{object}_#{method}", :function => "element.style.background = value" )
  end

  def show_date(date)
    _('%{year}/%{month}/%{day}') % {:day => '%02d' % date.day, :month => '%02d' % date.month, :year => '%04d' % date.year}
  end

  def show_image(image, size = "50x50")
    link_to(
      content_tag('span', image_tag(url_for_image_column(image, 'picture', :name => 'thumb'), :size => size)) +
      content_tag('span', image.description),
      url_for_image_column(image, 'picture', :name => 'medium'),
      { :class => 'product_image', :popup => [ 'abelo_image', 'height=240,width=320' ] }
    )
  end

  def notice_box(msg)
    return if msg.nil?
    content_tag(
      'div',
       [
         content_tag(
           :p, 
           msg
         ),
         javascript_tag(visual_effect(:toggle_slide, 'notice', :duration => 3))
      ].join("\n"),
      { :id => 'notice' }
    )
  end

  def display_navigation_bar
    content_tag(
      'div',
      [
        content_tag(
        'div',
        [
          #alterar para usar as funções do rails
          content_tag('a',[] ,:class => 'hide', :accesskey => 'z',:onclick => "$('warp').style.marginTop='-77px';"),
          content_tag('a',[] ,:class => 'show', :accesskey => 'x',:onClick => "$('warp').style.marginTop='0px';"),
        ],
        :class => 'control_header'),
        link_to(@organization.name, :controller => 'main'),
        if controller.controller_name != 'main'
        "&rarr " + link_to(controller.describe(@item), :controller => params[:controller])
        end
      ],
      :class => 'navigation_bar'
    ) if @organization
  end

  def main_menu
    menu_items = {
      'categories'                          => _('Configurations'),
      'stock'                               => _('Stock'),             
      'store'                               => _('Store'),  
      'permissions'                         => _('User administration'),  
      'system_actors'                       => _('Registers'),
      'point_of_sale'                       => _('Point of sale'),
      'mass_mails'                          => _('Mass mail'),
      'ledgers'                             => _('Financial'),
      'documents'                           => _('Documents'),
      'departments'                         => _('Departments'),
      'admin_configurations'                => _('Configurations'),
      'organizations'                       => _('Organizations'),
      'banks'                               => _('Banks'),
    }
    x = 0
   content_tag(
     'div', 
     content_tag( 
       'div',
       [content_tag(
         'ul', 
          menu_items.keys.select do |controller|
            can(:controller => controller)
          end.map do |controller|
            x = x+1
            content_tag('li',  design_display_icon(controller, menu_items[controller], { :controller => controller }, :id => controller, :class => "button_main pos_#{x}"))
          end.join("\n")) ]
       ), :id => 'nav', :style => "display : none;" )
  end

  def link_to_organization(org, html_options = {})
    link_to org.name, { :organization_nickname => org.nickname, :controller => 'main', :action => 'index' }, html_options
  end

  def multiple_select(object, method, collection=[], title="", value_method=:id, text_method=:name)
    value_method = value_method.to_s
    text_method = text_method.to_s
    selected_options = controller.instance_variable_get("@#{object}").send(method)
    content_tag('p', 
      {
      content_tag('label', title),
      collection.map do |c|
        if selected_options.include? c
          content_tag('input', c.send(text_method) , :name => "#{object}[#{method.singularize}_ids][]", :type => 'checkbox', :value => c.send(value_method) , :checked => 'checked' )
        else
          content_tag('input', c.send(text_method) , :name => "#{object}[#{method.singularize}_ids][]", :type => 'checkbox', :value => c.send(value_method) )
        end
      end
      }
    )
  end

  def rich_text_editor(object, method, options = {})
    fckeditor_textarea(object, method, options.merge({:toolbarSet => 'Simple', :height => '300px'}))
  end

  def select_categories(object, category_type)
    @organization.send("#{category_type}_categories").map { |c|
      content_tag('div',
        check_box_tag("categories[#{c.id}]", 1, object.send("#{category_type}_categories").include?(c)) + c.name
      )
    }.join('')
  end

 def options_for_category(cat, selected_value)
    if cat.leaf?
      content_tag('option', cat.name, "value" => cat.id)
    else
      options = { :label => cat.name, :style => "padding-left: #{cat.level}em;" }
      options.merge!(:selected => 'selected') if (selected_value == cat.id)
      content = cat.children.map { |child| options_for_category(child, selected_value) }.join('')
      content_tag("optgroup", content, options)
    end
  end

  def select_category(object, category_type)
    instance_object = self.instance_variable_get("@#{object}")
    categories = instance_object.organization.send("top_level_#{category_type}_categories")
    select_tag("#{object}[category_id]", categories.map { |c| options_for_category(c,instance_object.send('category_id')) }.join('') )
  end

#TODO see
  def to_currency(value)
    value = 0.0 if value.nil?
    number_to_currency(value, :unit => "", :delimiter => ".", :separator => ",")
  end

#TODO see
  def sum_by_category(type, obj)
    if type == :all
      obj.sum {|l| l.value * (l.category.expense? ? -1 : 1) }
    elsif type == :income
      obj.select {|l| l.category.income? }.sum {|l| l.value }
    elsif type == :expense
      obj.select {|l| l.category.expense? }.sum {|l| l.value }
    end
  end

#TODO see
  def navigator_for(pages, objs, flash, color='ligth_blue')
    str  = "<div class='#{color} navigation' style='text-align:center'>"
      if flash[:filter]
        str += flash[:filter]
        str += " [" + link_to_remote('limpar', :url => {:action => 'find_ledgers', :find => ''}) + "]"
      elsif pages.length > 1
        if pages.current.previous
          str += "<div style='float:left; position:absolute'>" + link_to_remote("&lt;recentes", :url => { :action => 'navigation', :page => pages.current.previous }) + "</div>"
        end
        if pages.current.next
          str += "<div style='float:right; display:table-cell'>" + link_to_remote('antigos&gt;', :url => { :action => 'navigation', :page => pages.current.next }) + "</div>"
        end
        str += "página #{pages.current.number} de #{pages.length}"
      end
    str  += "</div>"
  end




  def display_table(titles, content, html_options = {}, caption = nil)

    content_tag('table',[
        display_table_caption(caption, html_options[:html_caption_options]),
        display_table_head(titles, html_options[:html_title_options]),
        display_table_content(content, html_options[:html_content_options])
      ]
    )
  end

  def display_table_caption(caption, html_options)
    if !caption.nil?
      content_tag('caption', caption, html_options)
    end
  end

  def display_table_content(content_line, html_options)
    n = content_line.size
    content_line.map do |content_cel|
      n = n - 1
      p = -1
      content_tag('tr',[
        content_cel.map do |c|
          p = p + 1
          if n == 0 #last row
            content_tag('td', c, cel_options(html_options[p]))
          else
            content_tag('td', c, html_options[p])
          end
        end
      ], :class => line_class(n)) 
    end
  end

  def cel_options(options)
    options[:class] = options[:class] + ' ' + 'endrow'
    return options
  end

  def line_class(line)
    line.odd? ? 'odd': 'even'
  end

  def display_table_head (titles, html_options)
    tmp_html_options = Array.new

    if html_options === Array
      html_options = [:class => 'head'] if html_options.blank?
      while(tmp_html_options.length < titles.length)
        tmp_html_options.push(html_options.clone)
        tmp_html_options.flatten!
      end
    end
    tmp_html_options = tmp_html_options.first(titles.length)
    p = -1
    content_tag('tr', 
      titles.map do |t|
        p = p + 1
        content_tag('th', t, tmp_html_options[p]) 
      end
    )  
  end

  def limit_string(s,tam=50)
    (!s.nil? && !s.empty? && s.size > tam) ? s.first(tam)+"..." : s
  end

  def show_item_bar(element_id,title)
    content_tag(
      'div',
      link_to_remote(title, {}, :class => "show_itembar", :style => "border-botttom: none;", :onclick => visual_effect(:toggle_slide, element_id) )
     )      
  end

  def hide_item_bar(element_id)
    content_tag(
      'p',
      link_to_remote(content_tag('span', 'Hide'), {},:class => 'hide_itembar',:onclick => visual_effect(:toggle_slide, element_id))
    )
  end

  def title(title)
    content_tag('h1', title)
  end

  def subtitle(subtitle)
    content_tag('h2', subtitle)
  end

  def display_list(content, html_options = {})
    content_tag(
      'li', 
      content.map{ |c|
        if c.class == Hash 
          content_tag(
            'div',
            content_tag('strong', c[:title]) + 
            " " +
            content_tag('span', c[:content]),
            :class => "list_item_#{c[:option]}"
          )
        else
          c
        end
      }.join("\n"),
      :class => html_options[:li_options])
  end

  def display_collection(collection = Array.new, &block)
    content = Array.new
    collection.each do |c| 
      content.push(
        display_collection_options(c) +
        capture(c, &block)
      )
    end

    concat( 
      content_tag(:ul, 
        content.map{|c|
          content_tag(:li, c)
#          content_tag(:br,'' ,:style => 'clear:both;') TODO this is needed
        }.join("\n"),
        :class => 'info_list'
      ), block.binding
    )
  end

  def display_collection_options(item)
    content_tag(:div,
      [
        button('view_small', _('Show'), :show, :action => 'show', :id => item.id),
        button('edit_small', _('Edit'), :edit, :action => 'edit', :id => item.id),
        button('del_small', _('Destroy'), :destroy, {:action => 'destroy', :id => item.id},
               :method => 'post', :confirm => _('Are you sure?'))
      ].join("\n"),
      :class => 'list_item_button'
    )
  end
end
