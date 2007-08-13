require File.dirname(__FILE__) + '/../test_helper'
require 'system_actors_controller'

# Re-raise errors caught by the controller.
class SystemActorsController; def rescue_action(e) raise e end; end

class SuppliersControllerTest < Test::Unit::TestCase

  include TestingUnderOrganization

  fixtures :organizations, :system_actors

  def setup
    @controller = SystemActorsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @organization_nickname = 'one'
    @organization = Organization.find_by_nickname 'one'
    login_as("quentin")
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'list'
  end

  def test_list
    get :list, :actor => 'supplier'

    assert_response :success
    assert_template 'list'

    assert_not_nil assigns(:system_actor_pages)
    assert_not_nil assigns(:system_actors)
    assert_kind_of Array, assigns(:system_actors)
    assigns(:system_actors).each  do |s|
      assert_kind_of Supplier, s
    end
  end

  def test_new
    get :new, :actor => 'supplier'

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:system_actor)
    assert_not_nil assigns(:actor)
    assert_kind_of Supplier, assigns(:system_actor)
    assert_equal @organization, assigns(:system_actor).organization
  end

  def test_create
    num_suppliers = Supplier.count

    post :create, :actor => 'supplier', :system_actor =>{:name=>"Some Name", :cpf => "403.786.765-63", :category_id => "20", :email => "test@mail.com"}


    assert_not_nil assigns(:system_actor)
    assert_not_nil assigns(:actor)
    assert_kind_of Supplier, assigns(:system_actor)
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_suppliers + 1, Supplier.count
  end

#TODO see these test below
#
  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:supplier)
    assert assigns(:supplier).valid?
  end

  def test_update
    post :update, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'list'
  end

  def test_destroy
    assert_not_nil Supplier.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Supplier.find(1)
    }
  end
end
