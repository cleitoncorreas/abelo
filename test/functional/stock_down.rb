require File.dirname(__FILE__) + '/../test_helper'
require 'stock_down_controller'

# Re-raise errors caught by the controller.
class StockDownController; def rescue_action(e) raise e end; end

class StockDownControllerTest < Test::Unit::TestCase

  under_organization :one

  def setup
    @controller = StockDownController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login_as("quentin")
    @product = Product.find(:first)
    @product_category = ProductCategory.find(:first)
    @organization = Organization.find(:first)
  end

  def create_product(params = {})
    Product.create!({:name => 'product one', :sell_price => 2.0, :unit => 'kg', :organization => @organization, :category => @product_category}.merge(params))
  end

  def create_stock
    StockDown.create!(:amount => 1, :product => @product, :date => Date.today)
  end

  def create_supplier(params = {})
    Supplier.create!(
      {
        :name => "Some Name",
        :cpf => '182.465.232-10',
        :category_id => '20',
        :email => 'test@test.com',
        :organization => @organization
      }.merge(params)
    )
  end

  def test_setup
    assert @product.valid?
    assert @organization.valid?
    assert @product_category.valid?
  end

  def test_autocomplete_supplier_name
    Supplier.destroy_all
    create_supplier(:name => 'test one', :cpf => '112.767.281-90')
    create_supplier(:name => 'test two', :cpf => '546.261.286-96')
    create_supplier(:name => 'another one', :cpf => '687.618.228-25')
    get :autocomplete_supplier_name, :supplier => {:name => 'test'}
    assert_response :success
    assert_template 'stock_base/autocomplete_supplier_name'
    assert_not_nil assigns(:suppliers)
    assert_kind_of Array, assigns(:suppliers)
    assert_equal 2, assigns(:suppliers).length
  end

  def test_autocomplete_product_name
    Product.destroy_all
    create_product(:name => 'product one')
    create_product(:name => 'product two')
    create_product(:name => 'another')
    get :autocomplete_product_name, :product => {:name => 'product'}
    assert_response :success
    assert_template 'stock_base/autocomplete_product_name'
    assert_not_nil assigns(:products)
    assert_kind_of Array, assigns(:products)
    assert_equal 2, assigns(:products).length
  end

  def test_index
    get :index
    assert_response :redirect
    assert_redirected_to :action => 'list'
  end

  def test_list
    get :list
    assert_response :success
    assert_template 'stock_base/list'
    assert_not_nil assigns(:stocks)
    assert_not_nil assigns(:title)
    assert_not_nil assigns(:stock_pages)
  end

  def test_list_when_query_param_is_nil
    get :list

    assert_nil assigns(:query)
    assert_not_nil assigns(:stocks)
    assert_kind_of Array, assigns(:stocks)
    assert_not_nil assigns(:stock_pages)
    assert_kind_of ActionController::Pagination::Paginator, assigns(:stock_pages)
  end

  def test_list_when_query_param_not_nil
    Product.delete_all
    create_product(:name => 'product one')
    create_product(:name => 'product two')
    create_product(:name => 'another')
    get :list, :query => 'product*'

    assert_not_nil assigns(:query)
    assert_not_nil assigns(:stocks)
    assert_kind_of Array, assigns(:stocks)
    assert_not_nil assigns(:stock_pages)
    assert_kind_of ActionController::Pagination::Paginator, assigns(:stock_pages)

    assert_equal 2, assigns(:stocks).length
  end
 
  def test_new
    get :new
    assert_response :success
    assert_template 'stock_base/new'
    assert_not_nil assigns(:products)
    assert_not_nil assigns(:title)
    assert_not_nil assigns(:stock)
  end

  def test_new_with_product_id_param
    get :new, :product_id => @product.id
    assert_response :redirect
    assert_redirected_to :action => 'add'
  end

  def test_add
    get :add, :product_id => @product.id
    assert_response :success
    assert_template 'stock_base/add'
    assert_not_nil assigns(:stock)
    assert_not_nil assigns(:title)
    assert_equal @product, assigns(:stock).product
  end

  def test_create
    count_stock = StockDown.count

    post :create, :stock => { :product_id => @product.id, :amount => 1, :date => Date.today}

    assert_response :redirect
    assert_redirected_to :action => 'history'
    assert_equal count_stock + 1, StockDown.count
  end

  def test_create_with_wrong_params_of_add_action
    count_stock = StockDown.count

    # The amount cannot be nil
    post :create, :stock => { :product_id => @product.id, :amount => nil, :date => Date.today}, :product_id => @product.id

    assert_response :success
    assert_template 'stock_base/add'
  end

  def test_create_with_wrong_parameters
    count_stock = StockDown.count
    # The amount cannot be nil
    post :create, :stock => { :product_id => @product.id, :amount => nil, :date => Date.today}

    assert_response :success
    assert_template 'stock_base/new'
    assert_not_nil assigns(:stock)
    assert_not_nil assigns(:title)
    assert_not_nil assigns(:stock).errors
    assert_equal count_stock, StockDown.count
  end

  def test_history
    get :history, :product_id => @product.id
    assert_response :success
    assert_template 'stock_base/history'
    assert_not_nil assigns(:stocks)
    assert_not_nil assigns(:product)
    assert_not_nil assigns(:title)
  end

  def test_destroy
    stock = create_stock
    stock_id = stock.id
    get :destroy, :id => stock.id
    assert_raise(ActiveRecord::RecordNotFound) {
      assert StockDown.find(stock_id)
    }
    
    assert_response :redirect
    assert_redirected_to :action => 'history'
  end

  def test_show
    stock = create_stock
    get :show, :id => stock.id
    assert_response :success
    assert_template 'stock_base/show'
    assert_not_nil assigns(:stock)
  end

  def test_edit
    stock = create_stock
    get :edit, :id => stock.id

    assert_response :success
    assert_template 'stock_base/edit'

    assert_not_nil assigns(:title)
    assert assigns(:stock)
    assert assigns(:products)
  end

  def test_update
    stock = create_stock
    post :update, :id => stock.id, :stock => { :date => Date.today }

    assert_response :redirect
    assert_redirected_to :action => 'list'
  end

  def test_update_with_wrong_params
    stock = create_stock
    # The date could not be nil
    post :update, :id => stock.id, :stock => { :date => nil }

    assert_response :success
    assert_template 'stock_base/edit'
    assert_not_nil assigns(:stock)
    assert_not_nil assigns(:title)
    assert_not_nil assigns(:products)
  end

  def test_update_date
    stock = create_stock
    stock.date = DateTime.now
    new_date = DateTime.now + 1
    
    post :update, :id => stock.id, :stock => { :date => new_date }

    assert_equal new_date.to_s, StockDown.find(stock.id).date.to_datetime.to_s
  end

  def test_update_product
    stock = create_stock
    stock.product_id = 1
    new_product_id = 2
    
    post :update, :id => stock.id, :stock => { :product_id => new_product_id }

    assert_equal new_product_id, StockDown.find(stock.id).product_id
  end

  def test_update_amount
    stock = create_stock
    stock.amount = 1
    stock.save
    # Be carefull. We have to put a possible amount.
    # The amount must exist on stoq
    new_amount = -3
    
    post :update, :id => stock.id, :stock => { :amount => new_amount }

    assert_equal new_amount, StockDown.find(stock.id).amount
  end

end