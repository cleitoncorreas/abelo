class LedgerCategoryDisplay < DisplayConfiguration

  def self.available_fields
    ['name', 'interests', 'interests_days', 'number_of_parcels', 'is_operational', 'is_store', 'is_stock', 'type_of', 'payment_methods']
  end

  def self.describe(field)
    {
      'name' =>  _('Name'),
      'interests' =>  _('Interests'),
      'interests_days' =>  _('Days of Interests'),
      'number_of_parcels' =>  _('Number of Parcels?'),
      'is_operational' =>  _('Is Operational?'),
      'is_store' =>  _('Is to Store?'),
      'is_stock' =>  _('Is to Stock?'),
      'type_of' =>  _('Type of'),
      'payment_methods' =>  _('Payment Methods'),
    }[field] || field
  end

end
