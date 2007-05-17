class CreateHistoricals < ActiveRecord::Migration
  def self.up
    create_table :historicals do |t|
      t.column :name, :string, :null => false
      t.column :type_of, :char, :null => false
    end
  end

  def self.down
    drop_table :historicals
  end
end
