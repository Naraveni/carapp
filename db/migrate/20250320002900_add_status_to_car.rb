class AddStatusToCar < ActiveRecord::Migration[7.1]
  def change
    add_column :cars, :status, :integer
  end
end
