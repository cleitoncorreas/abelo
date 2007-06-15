require File.dirname(__FILE__) + '/../test_helper'
require 'commercial_proposals_controller'

# Re-raise errors caught by the controller.
class CommercialProposalsController; def rescue_action(e) raise e end; end

class CommercialProposalsControllerTest < Test::Unit::TestCase
  fixtures :commercial_proposals, :departments, :commercial_proposal_sections, :organizations, :commercial_proposals_departments, :commercial_proposal_items
  under_organization :one
  
  def setup
    @controller = CommercialProposalsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login_as("quentin")
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

    assert_not_nil assigns(:commercial_proposals)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:commercial_proposal)
    
    cp = CommercialProposal.find(1)
    cp.add_departments(Department.find(1))
    assert_valid assigns(:commercial_proposal)
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:commercial_proposal)
    assert_not_nil assigns(:departments)
    assert_kind_of Array, assigns(:departments)
    assigns(:departments).each do |d|
      assert d.valid?
    end
  end

  def test_create_correct_params
    num_commercial_proposals = CommercialProposal.count

    post :create, :commercial_proposal => {:organization_id => 1, :name => 'Any Name', :department_ids => [1,2] }

    assert_valid assigns(:commercial_proposal)
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_commercial_proposals + 1, CommercialProposal.count
  end

  def test_create_wrong_params
    num_commercial_proposals = CommercialProposal.count

    post :create, :commercial_proposal => {:organization_id => 1 }

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:departments)
    assert_kind_of Array, assigns(:departments)
    assigns(:departments).each do |d|
      assert d.valid?
    end

    assert_equal num_commercial_proposals, CommercialProposal.count
  end


  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:commercial_proposal)
    assert_not_nil assigns(:departments)
    assert_kind_of Array, assigns(:departments)
    assigns(:departments).each do |d|
      assert_valid d
    end
    cp = CommercialProposal.find(1)
    cp.add_departments(Department.find(1))
    assert_valid assigns(:commercial_proposal)
  end

  def test_update_correct_params
    post :update, :id => 1, :commercial_proposal => {:organization_id => 1, :name => 'Any Name', :department_ids => [1,2] }

    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
  end

  def test_update_wrong_params
    count = CommercialProposal.count
    cp = CommercialProposal.new
    cp.name = "Any Name"
    cp.organization_id=2
    assert cp.save
    assert_equal count + 1, CommercialProposal.count
    post :update, :id => cp.id, :commercial_proposal => {:organization_id => 1}

    assert_response :success
    assert_template 'edit'
    assert_not_nil assigns(:departments)
    assert_kind_of Array, assigns(:departments)
    assigns(:departments).each do |d|
      assert d.valid?
    end

  end

  def test_destroy
    assert_not_nil CommercialProposal.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      CommercialProposal.find(1)
    }
  end

  def test_choose_template
    get :choose_template
    assert_response :success
    assert_template 'choose_template'
    assert_not_nil assigns(:templates)
    assert_equal 1, assigns(:templates).size
  end

  def test_new_from_template
    get :new_from_template, :id => 1
    assert_response :success
    assert_template 'new'
    assert_not_nil assigns(:commercial_proposal)
    assert_not_equal assigns(:commercial_proposal).name, CommercialProposal.find(1).name
    assert_equal assigns(:commercial_proposal).body, CommercialProposal.find(1).body
  end

  def test_new_section
    get :new_section, :id => 1
    assert_not_nil assigns(:commercial_proposal_section)
    assert_not_nil assigns(:commercial_proposal_id)
    assert_response :success
    assert_template 'commercial_proposals/add_section'
  end

  def test_add_section
    get :add_section, :commercial_proposal_section => {:name => 'Section for testing'}, :id => 1
    assert_not_nil assigns(:commercial_proposal)
    assert_not_nil assigns(:sections)
    assert_response :success
    assert_template '_sections'
  end

  def test_new_item
    get :new_item, :id => 1, :commercial_proposal_id => 1
    assert_not_nil assigns(:commercial_section_id)
    assert_not_nil assigns(:commercial_proposal_id)
    assert_response :success
    assert_template 'commercial_proposals/add_item'
  end

  def test_add_item
    get :add_item, :commercial_section_item => {:name => 'Name of section for testing', :quantity => 5, :unitary_value => 2.0, :type_of => 'type for testing', :commercial_proposal_section_id => 1}, :id => 1, :commercial_proposal_id => 1
    assert_not_nil assigns(:commercial_proposal)
    assert_not_nil assigns(:sections)
    assert_response :success
    assert_template '_sections'
  end

end
