require File.dirname(__FILE__) + '/../test_helper'
require 'products_controller'

# Re-raise errors caught by the controller.
class ProductsController; def rescue_action(e) raise e end; end

class ProductsControllerTest < Test::Unit::TestCase

  fixtures :products, :system_actors, :categories, :configurations

  under_organization :one

  def setup
    @controller = ProductsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @organization = Organization.find_by_identifier 'one'
    @category = ProductCategory.find(:first)
    login_as("quentin")
  end

  def test_setup
    assert @organization.valid?
    assert @category.valid?
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'list'
  end

  def test_list
    get :list

    assert_response :success
    assert_template 'list'

    assert_not_nil assigns(:products)
    assert_kind_of Array, assigns(:products)
  end

  def test_autocomplete_name
    Product.delete_all
    product = Product.create!(:name => 'test product', :sell_price => 2.0, :unit => 'kg', :organization => @organization, :category => @category)
    get :autocomplete_name, :product => { :name => 'test'}
    assert_not_nil assigns(:products)
    assert_kind_of Array, assigns(:products)
    assert_equal 1, assigns(:products).length
  end

  def test_list_when_query_param_not_nil
    Product.delete_all
    Product.create!(:name => 'Some Product', :sell_price => '20', :unit => 'U', :organization_id => 1, :category_id => 1)
    Product.create!(:name => 'Another Product', :sell_price => '25', :unit => 'U', :organization_id => 1, :category_id => 1)
    Product.create!(:name => 'Product Three', :sell_price => '30', :unit => 'U', :organization_id => 1, :category_id => 1)
    get :list, :query => 'Another*' 

    assert_not_nil assigns(:query)
    assert_not_nil assigns(:products)
    assert_kind_of Array, assigns(:products)
    assert_not_nil assigns(:product_pages)
    assert_kind_of ActionController::Pagination::Paginator, assigns(:product_pages)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:product)
    assert assigns(:product).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:product)
    assert_kind_of Product, assigns(:product)
    assert_equal @organization, assigns(:product).organization
  end

  def test_create
    count = Product.count
    supplier = Supplier.find(:first)
    assert supplier.valid?

    post :create, :id => 1, :product => {:name => 'Some Product', :sell_price => '20', :unit => 'U', :organization_id => 1, :category_id => 1, :supplier_ids => [supplier.id.to_s] }
    assert_response :redirect
    assert_redirected_to :action => 'list'
  end
  
  def test_create_with_entry
    count = Product.count
    supplier = Supplier.find(:first)
    count = StockIn.count
    assert supplier.valid?

    post :create, :id => 1, :product => {:name => 'Some Product', :sell_price => '20', :unit => 'U', :organization_id => 1, :category_id => 1, :supplier_ids => [supplier.id.to_s] }, :entry => { :supplier_id => 3, :amount => 1, :price => 1.99, :purpose => 'sell', :date => '2007-01-01' }

    assert_not_nil assigns(:entry)
    assert_response :redirect
    assert_redirected_to :action => 'list'
    assert count+1, StockIn.count
  end

  def test_create_wrong_params
    num_products = Product.count
    post :create, :product => {}

    assert_response :success
    assert_template 'new'

    assert_equal num_products, Product.count
  end

  def test_edit
    Product.delete_all
    Product.create!(:name => 'Some Product', :sell_price => '20', :unit => 'U', :organization_id => 1, :category_id => 1)
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:product)
    assert assigns(:product).valid?
  end

  def test_edit_product_not_found
    Product.delete_all
    Product.create!(:name => 'Some Product', :sell_price => '20', :unit => 'U', :organization_id => 1, :category_id => 1)
    get :edit, :id => 2

    assert_response :success
    assert_template 'shared/not_found'
  end

  def test_update
    post :update, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'list'
  end

  #TODO make this test with :name => nil

  def test_update_with_wrong_params
    product = Product.new
    product.name = 'Test Department'
    product.sell_price = 20
    product.unit = 'one'
    product.organization_id = 1
    product.category_id = 1
    assert product.save
    post :update, :id => product.id,:product => {:name => nil }
    assert_response :success
    assert_not_nil assigns(:product)
    assert_not_nil assigns(:sizes)
    assert_not_nil assigns(:colors)
    assert_not_nil assigns(:units)
    assert_template 'edit'
  end

  #TODO make this test
#  def test_remove_supplier
#    supplier = Product.find(1).suppliers.find(:first)
#    product_count = supplier.products.count
#
#    post :update, :id => 1, :suppliers => { }
#    assert_response :redirect
#    assert_redirected_to :action => 'list'
#
#    assert_equal product_count - 1, supplier.products.count
#  end

  def test_destroy
    assert_not_nil Product.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Product.find(1)
    }
  end


  def test_images
    post :images, :id => 1
    assert_template 'images'
    assert_not_nil assigns(:product)
    assert_not_nil assigns(:image)
    assert_equal 1, assigns(:product).id
  end

  def test_add_images
    images_count = @organization.products.find(1).images.size

    post :add_image, :id => 1, :image => { :description => 'a test image', :picture => File.open(File.join(RAILS_ROOT,'public/images/rails.png')) }

    assert_redirected_to :action => 'images'
    assert_equal images_count + 1, @organization.products.find(1).images.size
  end

  def test_add_image_not_saved

    post :add_image, :id => 1, :image => {}

    assert_response :success
    assert_template 'images'
  end

  def test_remove_image
    post :add_image, :id => 1, :image => { :description => 'a test image', :picture => File.open(File.join(RAILS_ROOT,'public/images/rails.png')) }
    images_count = @organization.products.find(1).images.size

    post :remove_image, :image_id => @organization.products.find(1).image.id

    assert_redirected_to :action => 'images'
    assert_equal images_count - 1, @organization.products.find(1).images.size
  end

  def test_new_stock_entry
    get :new_stock_entry
    assert_response :success
  end

end
