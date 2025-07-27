class AddNameToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :name, :string, null: false, default: 'Unknown User'

    # Remove the default after adding the column (optional, for cleaner schema)
    change_column_default :users, :name, nil
  end
end