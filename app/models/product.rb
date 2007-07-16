# == Schema Information
# Schema version: 35
#
# Table name: products
#
#  id              :integer       not null, primary key
#  description     :string(255)   not null
#  size            :string(255)   
#  color           :string(255)   
#  sell_price      :float         not null
#  unit            :string(255)   not null
#  organization_id :integer       not null
#  category_id     :integer       not null
#

class Product < ActiveRecord::Base

  belongs_to :organization
  belongs_to :category, :class_name => 'ProductCategory', :foreign_key => 'category_id'
  has_many :images
  has_and_belongs_to_many :suppliers
  has_many :stock_entries

  validates_presence_of :description, :sell_price, :unit

  validates_presence_of :organization_id, :message => 'Products must be associated to an organization'

  validates_presence_of :category_id, :message => 'Every product must belong to a category'

  def ammount_in_stock
    self.connection.select_value('select sum(ammount) from stock_entries where product_id = %d' % self.id).to_f
  end

  def total_cost
    self.connection.select_value('select sum(ammount * price) from stock_entries where product_id = %d' % self.id).to_f
  end

  def image
    self.images.find(:first)
  end

end
