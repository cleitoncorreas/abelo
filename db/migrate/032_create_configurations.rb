class CreateConfigurations < ActiveRecord::Migration
  def self.up
    create_table :configurations do |t|
      t.column :is_model,           :boolean
      t.column :name,               :string
      t.column :description,        :text
      t.column :organization_id,    :integer
      t.column :full_product,       :text
      t.column :lite_product,       :text
      t.column :full_customer,      :text
      t.column :lite_customer,      :text
      t.column :full_worker,        :text
      t.column :lite_worker,        :text
      t.column :full_supplier,      :text
      t.column :lite_supplier,      :text
      t.column :department_name,    :string
      t.column :product_name,       :string
      t.column :customer_name,      :string
      t.column :organization_name,  :string
    end
  end

  def self.down
    drop_table :configurations
  end
end
