module StoreHelper

  def image_link(image, link = { } )
    link_to(
      content_tag('span',image_tag(url_for_image_column(image, 'picture', :name => 'thumb'))),
      link) if image
  end

  def category_hierarchy(category, separator = ' &rarr; ')
    c = category
    result = ''
    while c
      result = separator + link_to_unless_current(c.name, { :action => 'category', :id => c }) + result
      c = c.parent
    end
    result = link_to_unless_current(t(:start), { :action => '' }) + result
  end

  def randon(array)
    array.at(rand(array.size))
  end
end
