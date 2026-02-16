class AddReadStatusToMessages < ActiveRecord::Migration[8.1]
  def change
    add_column :messages, :read_by_users, :text
  end
end
