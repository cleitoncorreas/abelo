# == Schema Information
# Schema version: 35
#
# Table name: customers
#
#  id              :integer       not null, primary key
#  name            :string(255)   not null
#  email           :string(255)   not null
#  birthday        :date          
#  address         :string(255)   
#  cnpj            :string(14)    
#  cpf             :string(11)    
#  rg              :string(255)   
#  description     :text          
#  organization_id :integer       not null
#  category_id     :integer       
#

class Customer < ActiveRecord::Base

  belongs_to :organization
  has_many :contacts
  has_and_belongs_to_many :customer_categories, :join_table => 'customers_customer_categories'
  validates_presence_of :name, :email
  
  validates_presence_of :organization_id, :message => 'Customers must be associated to an organization'

  validates_as_cnpj :cnpj
  
  validates_as_cpf :cpf

  validates_uniqueness_of :cnpj, :scope => :organization_id, :if => lambda { |user| ! user.cnpj.blank? }, :message => 'There is another supplier with this %{fn}'
  validates_uniqueness_of :cpf, :scope => :organization_id, :if => lambda { |user| ! user.cpf.blank? }, :message => 'There is another supplier with this %{fn}'

  def validate
    
    if ((! self.cpf.blank?) && (! self.cnpj.blank?)) || (self.cpf.blank? && self.cnpj.blank?)
      errors.add('cnpj', 'Either %{fn} or CPF must be filled, and they cannot be filled at the same time.')
    end
  end

  def self.search(search_args, possible_ids = [], options = {} )
       return [] unless search_args

       search_args = '%' + search_args + '%'
       the_class = Customer 
       searched_people = Array.new
       if options == nil
         searched_people = the_class.find(:all, :conditions => [ '(name LIKE :search)', { :search =>  search_args } ] ).reject { |p| not possible_ids.include? p.id.to_s }
       else
      options.each_key { |o|
        if o == 'name'
          searched_people= searched_people + the_class.find(:all, :conditions => [ 'name LIKE :search', { :search =>  search_args } ] ).reject { |p| not possible_ids.include? p.id }
        elsif o == 'cpf'
          searched_people= searched_people + the_class.find(:all, :conditions => [ 'cpf LIKE :search', { :search =>  search_args } ] ).reject { |p| not possible_ids.include? p.id }
        elsif o == 'rg'
          searched_people= searched_people + the_class.find(:all, :conditions => [ 'rg LIKE :search', { :search =>  search_args } ] ).reject { |p| not possible_ids.include? p.id }
        end
      }

    end
    searched_people.uniq
  end

  def list_by_categories()

  end

end
