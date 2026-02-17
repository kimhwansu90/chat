class AddAdminFieldsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :role, :string, default: "user"
    add_column :users, :banned, :boolean, default: false
    add_column :users, :banned_at, :datetime
    add_column :users, :banned_reason, :string
    add_column :users, :last_seen_at, :datetime
  end
end
