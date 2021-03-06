require File.dirname(__FILE__) + '/../test_helper'

class OrganizationTest < Test::Unit::TestCase

  def setup
    create_place
    @organization = create_organization
    @customer_category = create_customer_category
    @customer = create_customer
    @department = create_department
    @product_category = create_product_category
    @worker_category = create_worker_category
    @supplier_category = create_supplier_category
    @ledger_category = create_ledger_category
    @user = create_user
    @bank = create_bank
    @bank_account = create_bank_account
#FIXME remove this
#User.create!("salt"=>"7e3041ebc2fc05a40c60028e2c4901a81035d3cd", "updated_at"=>nil, "crypted_password"=>"00742970dc9e6319f8019fd54864d3ea740f04b1", "type"=>"User", "remember_token_expires_at"=>nil, "id"=>"1", "administrator"=>false, "remember_token"=>nil, "login"=>"new_user", "email"=>"new_user@example.com", "created_at"=>"2007-07-14 18:03:29")
  end

  def create_document(params = {})
    Document.create!(
      {
        :name => 'Anohter Document Again', 
        :organization => @organization, 
        :is_model => false,
        :departments => [@department]
      }.merge(params)
    )
  end

  def test_setup
    assert @organization.valid?
    assert @product_category.valid?
    assert @customer_category.valid?
    assert @worker_category.valid?
    assert @supplier_category.valid?
  end


  def test_relation_with_departaments
    dept = Department.create(:name => 'Department for testing')
    @organization.departments.concat(dept)
    assert @organization.departments.include?(dept)
  end

  def test_relation_with_products
    product = create_product(:unit_measure => create_unit)
    @organization.products.concat(product)
    assert @organization.products.include?(product)
  end

  def test_relation_with_sales
    sale = create_sale(:user_id => 1)
    @organization.sales.concat(sale)
    assert @organization.sales.include?(sale)
  end

  def test_relation_with_mass_mails
    mail = MassMail.create!(:subject => "Email subject", :body => "Email body", :organization => @organization)
    @organization.mass_mails.concat(mail)
    assert @organization.mass_mails.include?(mail)
  end

  def test_relation_with_product_categories
    assert @organization.product_categories.include?(@product_category)
  end

  def test_relation_with_customer_categories
    assert @organization.customer_categories.include?(@customer_category)
  end

  def test_relation_with_worker_categories
    assert @organization.worker_categories.include?(@worker_category)
  end

  def test_relation_with_supplier_categories
    assert @organization.supplier_categories.include?(@supplier_category)
  end

  def test_relation_with_system_actors
    num_actors = @organization.system_actors.length
    supplier = Supplier.create!(:name => 'Hering', :cnpj => '58178734000145', :organization_id => @organization.id, :email => 'contato@hering.com', :category_id => @supplier_category.id)
    customer = Customer.create!(:name => 'João da Silva', :email => 'joao@softwarelivre.org', :cpf => '74676743920', :organization_id => @organization.id, :email => 'joao@softwarelivre.org', :category_id => @customer_category.id)
    worker = Worker.create!(:name => 'José Fernandes', :cpf => '63358421813', :category_id => @worker_category.id, :organization_id => @organization.id , :email => 'jose@toca.com')
    assert_equal num_actors + 3, @organization.system_actors.count
  end

  def test_relation_with_suppliers
    supplier = Supplier.create!(:name => 'Hering', :cnpj => '58178734000145', :organization_id => @organization.id, :email => 'contato@hering.com', :category_id => @product_category.id)
    assert @organization.suppliers.include?(supplier)
  end

  def test_relation_with_customers
    customer = Customer.create!(:name => 'João da Silva', :email => 'joao@softwarelivre.org', :cpf => '74676743920', :organization_id => @organization.id, :email => 'joao@softwarelivre.org', :category_id => @supplier_category.id)
    assert @organization.customers.include?(customer)
  end

  def test_relation_with_workers
    worker = Worker.create!(:name => 'José Fernandes', :cpf => '63358421813', :category_id => @worker_category.id, :organization_id => @organization.id , :email => 'jose@toca.com')
    assert @organization.workers.include?(worker)
  end

    def test_relation_with_profiles
    profile = Profile.create(:organization_id => @organization.id, :user_id => @user.id, :permissions => [:controller => '*', :action => '*'])
    assert @organization.profiles.include?(profile)
  end

  def test_users
   profile = Profile.create(:organization_id => @organization.id, :user_id => @user.id, :permissions => [:controller => '*', :action => '*'])
   assert @organization.users.include?(@user)
  end

#FIXME See the better way to make the association between contacts and organization
#  def test_relation_with_contact
#    customer= Customer.create!(:name => 'Hering', :cnpj => '58178734000145', :organization_id => @organization.id, :email => 'contato@hering.com', :category_id => @customer_category.id)
#    contact = Contact.create(:name => 'Contact for testing', :system_actor_id => customer.id, :category_id => @customer_category)
#    assert @organization.contact == contact
#  end

  def test_mandatory_field_name
    org = Organization.create(:cnpj => '63182452000151', :identifier => 'org')
    assert org.errors.invalid?(:name) 
  end

  def test_mandatory_field_identifier
    org = Organization.create(:name => 'Organization for testing', :cnpj => '63182452000151')
    assert org.errors.invalid?(:identifier)
  end

  def test_uniqueness_name
    org_1 = create_organization(:name => 'Organization for testing', :cnpj => '63182452000151', :identifier => 'org_1')
    org_2 = new_organization(:name => 'Organization for testing', :cnpj => '67444545000168', :identifier => 'org_2')
    org_2.valid?
    assert org_2.errors.invalid?(:name) 
  end

  def test_uniqueness_cnpj
    Organization.destroy_all
    org_1 = create_organization(:cnpj => '63182452000151', :identifier => 'org_1')
    org_2 = new_organization(:cnpj => '63182452000151', :identifier => 'org_2')
    org_2.valid?
    assert org_2.errors.invalid?(:cnpj) 
  end

  def test_uniqueness_identifier
    Organization.destroy_all
    org_1 = create_organization(:cnpj => '63182452000151', :identifier => 'org_1')

    org_2 = Organization.new(:identifier => 'org_1')
    org_2.valid?
    assert org_2.errors.invalid?(:identifier) 
  end

  def test_cnpj_format
    org = Organization.new(:name => 'Organization for testing', :identifier => 'org')
    org.cnpj = 'bli'
    org.valid?
    assert org.errors.invalid?(:cnpj)
    org.cnpj = '12121212121212'
    org.valid?
    assert org.errors.invalid?(:cnpj)
    org.cnpj = '66145476000129'
    org.valid?
    assert !org.errors.invalid?(:cnpj)
  end

  def test_identifier_format
    org = Organization.new(:name => 'Organization for testing', :cnpj => '63182452000151')
    org.identifier = 'invalid identifier'
    org.valid?
    assert org.errors.invalid?(:identifier)
    org.identifier = 'valid_identifier'
    org.valid?
    assert !org.errors.invalid?(:identifier)
  end

  def test_top_level_product_categories
    assert @organization.top_level_product_categories.include?(@product_category)
  end

  def test_top_level_supplier_categories
    assert @organization.top_level_supplier_categories.include?(@supplier_category)
  end

  def test_top_level_worker_categories
    assert @organization.top_level_worker_categories.include?(@worker_category)
  end
  
  def test_top_level_customer_categories
    assert @organization.top_level_customer_categories.include?(@customer_category)
  end

  def test_documents_model
    dept = Department.create!(:name => 'Department for testing', :organization_id => @organization.id)
    com_prop = Document.create!(:name => 'Commercial Proposal', :organization_id => @organization.id, :is_model => true, :department_ids => [dept.id])
    assert @organization.documents_model.include?(com_prop)
  end

  def test_document_not_model
    doc = create_document(:is_model => false, :owner => @customer)
    assert @organization.documents_not_model.include?(doc) 
  end

  def test_get_all_ledgers
    Ledger.destroy_all
    create_ledger
    create_ledger
    create_ledger
    n = Ledger.count 
    assert_equal n, @organization.ledgers.length
  end

  def test_get_specific_ledger
    Ledger.destroy_all
    l = create_ledger
    assert_equal l, @organization.ledgers.find(l.id)
  end

  def test_presence_of_address
    Organization.destroy_all
    o = new_organization(:country_id => nil)
    o.valid?
    assert o.errors.invalid?(:address), "Country cannot be nil"

    o = new_organization(:state_id => nil)
    o.valid?
    assert o.errors.invalid?(:address), "State cannot be nil"

    o = new_organization(:city_id => nil)
    o.valid?
    assert o.errors.invalid?(:address), "City cannot be nil"

    country = BSC::Country.find(:first)
    assert_not_nil country.nil?
    state = country.states.find(:first)
    assert_not_nil state.nil?
    city = state.cities.find(:first)
    assert_not_nil city.nil?
    o = new_organization(:country_id => country.id, :state_id => state.id, :city_id => city.id)
    count = Address.count
    assert o.save!
    assert_equal count + 1, Address.count
  end

  def test_country_object
    country = BSC::Country.find(:first)
    o = new_organization
    o.country_id = country.id
    assert_equal country, o.country_obj
  end

  def test_state_object
    state = BSC::State.find(:first)
    o = new_organization
    o.state_id = state.id
    assert_equal state, o.state_obj
  end

  def test_city_object
    city = BSC::City.find(:first)
    o = new_organization
    o.city_id = city.id
    assert_equal city, o.city_obj
  end

  def test_ledgers_by_tag
    o = create_organization(:identifier => 'some_id', :name =>'some name')
    account = create_bank_account(:organization => o)

    create_ledger(:owner => o, :tag_list =>['some'])
    create_ledger(:owner => o, :tag_list =>['another'])
    create_ledger(:owner => o, :tag_list =>['some'])
    create_ledger(:owner => o, :tag_list =>['some'])
    assert_equal 3, o.ledgers_by_tag(['some'],[account]).length
  end

  def test_ledgers_by_categories
    o = create_organization(:identifier => 'some_id', :name =>'some name')
    account = create_bank_account(:organization => o)
    c1 = create_ledger_category(:organization => o, :name => 'some name')
    c2 = create_ledger_category(:organization => o, :name => 'another name')
    c3 = create_ledger_category(:organization => o, :name => 'another again')
    create_ledger(:owner => o, :category => c1)
    create_ledger(:owner => o, :category => c1)
    create_ledger(:owner => o, :category => c2)
    create_ledger(:owner => o, :category => c3)
    assert_equal 3, o.ledgers_by_categories([c1,c2], [account]).length
  end

  def test_ledgers_by_dates
    o = create_organization(:identifier => 'some_id', :name =>'some name')
    account = create_bank_account(:organization => o)

    create_ledger(:owner => o, :date => Date.today)
    create_ledger(:owner => o, :date => Date.today + 1)
    create_ledger(:owner => o, :date => Date.today + 2)
    create_ledger(:owner => o, :date => Date.today - 1)
    create_ledger(:owner => o, :date => Date.today - 2)
    assert_equal 4, o.ledgers_by_dates(Date.today-1, Date.today + 2, [account]).length
  end

  def test_ledgers_by_search
    o = create_organization(:identifier => 'some_id', :name =>'some name')
    
    account = create_bank_account(:organization => o)

    create_ledger(:owner => o, :description =>'test description')
    create_ledger(:owner => o, :description =>'test again')
    create_ledger(:owner => o, :description =>'description')
    create_ledger(:owner => o, :description =>'none')
    assert_equal 2, o.ledgers_by_search('test', [account]).length
  end

  def test_ledgers_by_all
    o = create_organization(:identifier => 'some_id', :name =>'some name')
    account = create_bank_account(:organization => o)

    c1 = create_ledger_category(:organization => o, :name => 'some name')
    c2 = create_ledger_category(:organization => o, :name => 'another name')
    create_ledger(:owner => o, :description =>'test description', :tag_list => ['some'], :date => Date.today, :category => c1)
    create_ledger(:owner => o, :description =>'test again', :tag_list => ['some'], :date => Date.today - 20, :category => c2)
    create_ledger(:owner => o, :description =>'description', :tag_list => ['again'], :category => c1)
    create_ledger(:owner => o, :description =>'none', :category => c1, :tag_list => ['again'])
    assert_equal 2, o.ledgers_by_all([account], ['some'], [c1,c2], Date.today - 20, Date.today).length
    assert_equal 1, o.ledgers_by_all([account], ['some'], [c1], Date.today - 20, Date.today).length
    assert_equal 3, o.ledgers_by_all([account], ['some', 'again'], [c1,c2], Date.today, Date.today).length
  end

  def test_ledgers_by_all_is_sorted_by_date
    o = create_organization(:identifier => 'some_id', :name =>'some name')
    account = create_bank_account(:organization => o)
    create_ledger(:owner => o, :date => Date.today)
    create_ledger(:owner => o, :date => Date.today + 1)
    create_ledger(:owner => o, :date => Date.today - 1)
    create_ledger(:owner => o, :date => Date.today + 2)
    create_ledger(:owner => o, :date => Date.today - 2)
    date = nil
    ledgers = o.ledgers_by_all([account], [], [], Date.today - 3, Date.today+3)
    assert_equal 5, ledgers.length
    ledgers.each do |l|
      date ||= l.date
      assert date <= l.date
      date = l.date
    end
  end

  def test_tracker_association
    o = create_organization(:identifier => 'some_id', :name =>'some name')
    assert o.tracker
  end
end
