class << ActiveRecord::Base
  #FIXME make this test

  def acts_as_searchable(options = {}, ferret_options = {})
    acts_as_ferret({ :remote => true }.merge(options), ferret_options)
  end

end
