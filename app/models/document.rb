class Document < ActiveRecord::Base

  validates_presence_of :organization_id
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :organization_id
  validates_presence_of :document_model_id, :if => lambda {|dm|  not dm.is_model? }


  acts_as_ferret

  has_many :document_sections
  has_and_belongs_to_many :departments
  belongs_to :organization
  belongs_to :document_model, :class_name => 'Document', :foreign_key => 'document_model_id'

  def validate
#TODO see if it's need validate is_model like this
    self.errors.add('is_model', _('You have to choose an option to the template')) if self.is_model.nil?
    self.errors.add( _('You have to choose almost an department to the document')) if  (not self.organization.nil?) and (not self.organization.departments.empty?) and (self.departments.empty?)
  end

  def self.full_text_search(q, options = {})
    default_options = {:limit => :all, :offset => 0}
    options = default_options.merge options
    results = self.find_by_contents(q, options)
    return [results.size, results]
  end

end
