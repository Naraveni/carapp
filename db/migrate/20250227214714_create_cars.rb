class CreateCars < ActiveRecord::Migration[7.1]
  def change
    create_table :cars do |t|
      t.string :model
      t.datetime :manufactured_year
      t.integer :price_per_day
      t.timestamps
    end
  end
end
