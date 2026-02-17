class AddMessageTypeToMessages < ActiveRecord::Migration[8.1]
  def change
    add_column :messages, :message_type, :string, default: "text"
  end
end
