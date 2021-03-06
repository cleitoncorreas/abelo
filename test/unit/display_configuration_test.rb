require File.dirname(__FILE__) + '/../test_helper'

class DisplayConfigurationTest < Test::Unit::TestCase
  fixtures :configurations

  def setup
    @organization = create_organization
    @configuration = Configuration.find(:first)
    @other_configuration = Configuration.create!(:organization_name => 'Some Name',  :product_name => 'Some name', 
                         :department_name => 'Some Name', :customer_name => 'Some name', :document_name => 'Some Name', 
                         :organization => @organization, :organization_name_on_plural => 'Some name_on_plural', 
                         :product_name_on_plural => 'Some name_on_plural', :department_name_on_plural => 'Some name_on_plural',
                         :customer_name_on_plural => 'Some name_on_plural', :document_name_on_plural => 'Some name_on_plural')
  end

  def test_setup
    assert @configuration.valid?
    assert @other_configuration.valid?
    assert @organization.valid?
  end

  def test_scope_of_field_by_differents_display_objects_of_the_same_organization_configuration
    WorkerDisplay.create(:configuration => @configuration, :field => 'name')
    d = SupplierDisplay.new(:configuration => @configuration, :field => 'name')
    d.valid?
    assert !d.errors.invalid?(:field)
  end

  def test_title
    assert_raise(RuntimeError){ DisplayConfiguration.title}
  end

end
