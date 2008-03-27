class Article < ActiveRecord::Base

  belongs_to :environment
  validates_presence_of :name, :slug, :path

  validates_uniqueness_of :slug, :scope => ['environment_id', 'parent_id'], :message => _('%{fn} (the code generated from the article name) is already being used by another article.')

  belongs_to :last_changed_by, :class_name => Person.name, :foreign_key => 'last_changed_by_id'

  acts_as_taggable  
  N_('Tag list')

  acts_as_filesystem

  acts_as_versioned

  acts_as_searchable :fields => [:name, :abstract, :body, :tag_list ]

  # retrieves all articles belonging to the given +environment+ that are not
  # sub-articles of any other article.
  def self.top_level_for(environment)
    self.find(:all, :conditions => { :parent_id => nil, :environment_id => environment })
  end

  # retrieves the latest +limit+ articles, sorted from the most recent to the
  # oldest.
  def self.recent(limit)
    options = { :limit => limit, :order => 'created_on desc, articles.id desc' }
    self.find(:all, options)
  end

  # retrives the most commented articles, sorted by the comment count (largest
  # first)
  def self.most_commented(limit)
    find(:all, :order => 'comments_count DESC', :limit => limit)
  end

  # produces the HTML code that is to be displayed as this article's contents.
  #
  # The implementation in this class just provides the +body+ attribute as the
  # HTML.  Other article types can override this method to provide customized
  # views of themselves.
  def to_html
    body
  end

  # returns the data of the article. Must be overriden in each subclass to
  # provide the correct content for the article. 
  def data
    body
  end

  # provides the icon name to be used for this article. In this class this
  # method just returns 'text-html', but subclasses may (and should) override
  # to return their specific icons.
  #
  # FIXME use mime_type and generate this name dinamically
  def icon_name
    'text-html'
  end

  def mime_type
    'text/html'
  end

  def mime_type_description
    _('HTML Text document')
  end

  def title
    name
  end

  def self.short_description
    if self == Article
      _('Article')
    else
      _('"%s" article') % self.article_type_name
    end
  end

  def self.description
    if self == Article
      _('An ordinary article')
    else
      _('An article of type "%s"') % self.article_type_name
    end
  end

  def self.article_type_name
    self.name.gsub(/article$/i, '')
  end

  def url
    self.environment.url.merge(:page => path.split('/'))
  end

  def allow_children?
    true
  end

end
