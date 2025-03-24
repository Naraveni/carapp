class AddPermissionToUser < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :permission, :string
  end
end
