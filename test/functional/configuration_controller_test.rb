require File.dirname(__FILE__) + '/../test_helper'
require 'configuration_controller'

# Re-raise errors caught by the controller.
class ConfigurationController; def rescue_action(e) raise e end; end

class ConfigurationControllerTest < Test::Unit::TestCase
  
  include TestingUnderOrganization

  fixtures :historicals
  
  def setup
    @controller = ConfigurationController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @organization_nickname = 'one'
    @organization = Organization.find_by_nickname 'one'
    login_as("quentin") 
  end

  def test_index
    get :index
    assert_not_nil assigns(:objects)
    assert_not_nil assigns(:title)
    assert_response :success
    assert_template 'index'
  end

  def test_cash_flow
    get :cash_flow 
    assert_not_nil assigns(:models)
    assert_not_nil assigns(:title)
    assert_response :success
    assert_template 'models'
  end

  def test_list
    get :list, :model_name => 'historical'
    assert_not_nil assigns(:model_name)
    assert_not_nil assigns(:the_model)
    assert_not_nil assigns(:objects)
    assert_response :success
    assert_template '_list'
  end

  def test_new  
    get :new, :model_name => 'specification'
    assert_not_nil assigns(:model_name)
    assert_not_nil assigns(:the_model)
    assert_not_nil assigns(:object)
    assert_response :success
    assert_template '_new'
  end

  def test_new_historical  
    get :new, :model_name => 'historical'
    assert_not_nil assigns(:model_name)
    assert_not_nil assigns(:the_model)
    assert_not_nil assigns(:object)
    assert_response :success
    assert_template '_new_historical'
  end

  def test_edit
    get :edit, :model_name => 'specification', :id => 1
    assert_not_nil assigns(:model_name)
    assert_not_nil assigns(:the_model)
    assert_not_nil assigns(:object)
    assert_response :success
    assert_template '_edit'
  end

  def test_edit_historical
    get :edit, :model_name => 'historical', :id => 1
    assert_not_nil assigns(:model_name)
    assert_not_nil assigns(:the_model)
    assert_not_nil assigns(:object)
    assert_response :success
    assert_template '_edit_historical'
  end

  def test_update
    get :update, :model_name => 'historical', :id => 1
    assert_not_nil assigns(:model_name)
    assert_not_nil assigns(:the_model)
    assert_not_nil assigns(:object)
    assert_response :redirect
    assert_redirected_to :action => 'show'
  end

  def test_update_fails
    get :update, :model_name => 'historical', :id => 1
    h = Historical.find(1)
    h.organization_id = nil
    assert_not_nil assigns(:model_name)
    assert_not_nil assigns(:the_model)
    assert_not_nil assigns(:object)
    assert_response :success
    assert_template '_edit'
  end

end
