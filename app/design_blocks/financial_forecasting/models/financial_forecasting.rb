class FinancialForecasting < Design::Block

  # Define an specific method using the settings hash serialized 
  # variable to keep the value desired by method.
  #
  # EX: 
  #   def max_number_of_element= value
  #     self.settings[:limit_number] = value
  #   end

  def self.description
    _('Financial Forecasting')
  end

end
