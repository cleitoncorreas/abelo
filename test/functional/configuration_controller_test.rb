require File.dirname(__FILE__) + '/../test_helper'
require 'configuration_controller'

# Re-raise errors caught by the controller.
class ConfigurationController; def rescue_action(e) raise e end; end

class ConfigurationControllerTest < Test::Unit::TestCase

  under_organization :admin #TODO see the better way to do that. This are admin controllers

  def setup
    @controller = ConfigurationController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login_as('admin')
    @configuration = Configuration.create(:is_model => true, :organization_name => 'Some Name',
      :product_name => 'Some name', :department_name => 'Some Name',
      :customer_name => 'Some name', :document_name => 'Some Name')

  end

  def test_only_admin_has_access
    login_as('aaron')
    get :index
    assert_response 403
    get :list
    assert_response 403
    get :new
    assert_response 403
    get :edit
    assert_response 403
    get :create
    assert_response 403
    get :update
    assert_response 403
  end

  def test_autocomplete_name
    Configuration.destroy_all

    Configuration.create(:is_model => true, :organization_name => 'Some Name',
      :product_name => 'Some name', :department_name => 'Some Name',
      :customer_name => 'Some name', :document_name => 'Some Name')
    Configuration.create(:is_model => true, :organization_name => 'Some Name',
      :product_name => 'Some name', :department_name => 'Some Name',
      :customer_name => 'Some name', :document_name => 'Some Name')

    product = Configuration.create!(:name => 'test product', :identifier => 'some', :cnpj => '84.021.301/0001-91')
    product = Organization.create!(:name => ' product', :identifier => 'anothersome', :cnpj => '73.417.283/0001-45')
    get :autocomplete_name, :organization => { :name => 'test'}
    assert_not_nil assigns(:organizations)
    assert_kind_of Array, assigns(:organizations)
    assert_equal 1, assigns(:organizations).length
  end

  def test_index
    get :index
    assert_response :redirect
    assert_redirected_to :action => 'list'
  end

  def test_list
    get :list

    assert_response :success
    assert_template 'list'

    assert_not_nil assigns(:organizations)
    assert_kind_of Array, assigns(:organizations)
    assert_not_nil assigns(:organization_pages)
  end

  def test_show
    Organization.delete_all
    o = Organization.create!(:name => 'Some Organization', :identifier => 'testing_org', :cnpj => '78048802000169')
    get :show, :id => o.id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:organization)
    assert assigns(:organization).valid?
    assert_equal o.id, assigns(:organization).id
  end

  def test_new
    get :new

    assert_not_nil assigns(:organization)

    assert_response :success
    assert_template 'new'
  end

  def test_successfully_create
    num_organizations = Organization.count

    post :create, :organization => {:name => 'Some Organization', :identifier => 'testing_org', :cnpj => '78048802000169'}

    assert_response :redirect
    assert_redirected_to :controller => 'configuration', :action => 'edit'

    assert_equal num_organizations + 1, Organization.count
  end

  def test_save_name_on_create
    Organization.delete_all
    post :create, :organization => {:name => 'Some Organization', :identifier => 'testing_org', :cnpj => '78048802000169'}
    
    o = Organization.find(:first)
    assert_not_nil o
    assert o.valid?
    assert_equal 'Some Organization', o.name
  end

  def test_save_identifier_on_create
    Organization.delete_all
    post :create, :organization => {:name => 'Some Organization', :identifier => 'testing_org', :cnpj => '78048802000169'}
    
    o = Organization.find(:first)
    assert_not_nil o
    assert o.valid?
    assert_equal 'testing_org', o.identifier
  end

  def test_save_cnpj_on_create
    Organization.delete_all
    post :create, :organization => {:name => 'Some Organization', :identifier => 'testing_org', :cnpj => '78048802000169'}
    
    o = Organization.find(:first)
    assert_not_nil o
    assert o.valid?
    assert_equal '78048802000169', o.cnpj
  end


  def test_unsuccessfully_create
    num_organizations = Organization.count

    post :create, :organization => {:name => 'Some Organization', :identifier => 'testing_org'}

    assert_response :success
    assert_template 'new'
    assert assigns(:organization)

    assert_equal num_organizations, Organization.count
  end

  def test_edit
    Organization.delete_all
    o = Organization.create!(:name => 'Some Organization', :identifier => 'testing_org', :cnpj => '78048802000169')
    get :edit, :id => o.id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:organization)
    assert assigns(:organization).valid?
  end


  def test_successfully_update
    Organization.delete_all
    o = Organization.create!(:name => 'Some Organization', :identifier => 'testing_org', :cnpj => '78048802000169')
    num_organizations = Organization.count
    post :update, :id => o.id, :organization => {:name => 'Another Organization'}

    assert_response :redirect
    assert_redirected_to :action => 'show'

    assert_equal num_organizations, Organization.count
  end

  def test_save_name_on_update
    Organization.delete_all
    o = Organization.create!(:name => 'Some Organization', :identifier => 'testing_org', :cnpj => '78048802000169')
    post :update, :id => o.id, :organization => {:name => 'Another Organization'}

    o = Organization.find(:first)
    assert_not_nil o
    assert o.valid?
    assert_equal 'Another Organization', o.name
  end


  def test_save_cnpj_on_update
    Organization.delete_all
    o = Organization.create!(:name => 'Some Organization', :identifier => 'testing_org', :cnpj => '78048802000169')
    post :update, :id => o.id, :organization => {:cnpj => '62.370.998/0001-73'}

    o = Organization.find(:first)
    assert_not_nil o
    assert o.valid?
    assert_equal '62.370.998/0001-73', o.cnpj
  end

  def test_unsuccessfully_update
    Organization.delete_all
    Organization.create!(:name => 'Another Some Organization', :identifier => 'another_testing_org', :cnpj => '62.370.998/0001-73')
    o = Organization.create!(:name => 'Some Organization', :identifier => 'testing_org', :cnpj => '78048802000169')
    num_organizations = Organization.count
    post :update, :id => o.id, :organization => {:cnpj => '62.370.998/0001-73'}

    assert_response :success
    assert_template 'edit'
    assert assigns(:organization)

    assert_equal num_organizations, Organization.count
  end

  def test_destroy
    id = @organization.id

    post :destroy, :id => id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Organization.find(id)
    }
  end

end