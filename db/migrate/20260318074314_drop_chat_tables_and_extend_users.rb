class DropChatTablesAndExtendUsers < ActiveRecord::Migration[8.1]
  def change
    drop_table :reports, if_exists: true
    drop_table :messages, if_exists: true
    drop_table :conversations, if_exists: true

    change_column_default :users, :role, from: "user", to: "sales_rep"

    add_column :users, :email, :string
    add_column :users, :phone, :string
    add_column :users, :active, :boolean, default: true, null: false

    add_index :users, :email, unique: true, where: "email IS NOT NULL"
    add_index :users, :role
  end
end
