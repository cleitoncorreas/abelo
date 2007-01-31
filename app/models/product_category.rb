class ProductCategory < ActiveRecord::Base

  validates_presence_of :name, :organization_id
  belongs_to :organization
  has_many :products, :foreign_key => 'category_id'
  has_many :images, :through => :products
  acts_as_tree :order => 'name'

  def full_name(sep = '/')
    self.parent ? (self.parent.full_name(sep) + sep + self.name) : (self.name)
  end
  def level
    self.parent ? (self.parent.level + 1) : 0
  end
  def top_level?
    self.parent.nil?
  end
  def leaf?
    self.children.empty?
  end
  
  def self.top_level_for(organization)
    self.find(:all, :conditions => ['parent_id is null and organization_id = ?', organization.id ])
  end

  def category_images(images = [])
    if self.leaf?
      images += self.images
    else
      self.children.each do |c|
        images += c.category_images(images)
      end
    end
    images
  end

end
