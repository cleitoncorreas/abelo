class StoreController < ApplicationController
  
  needs_organization 

  def index
    redirect_to :action => 'list'
  end

  def list
    if params[:product_category]
      @product_categories = ProductCategory.find(params[:product_category]).children
    else
      @product_categories = @organization.top_level_product_categories
    end
  end

  def list_products 
    pc = ProductCategory.find(params[:product_category]) 
    @products = pc.products
  end

  def show_product
    @product = Product.find(params[:product])
  end

end
