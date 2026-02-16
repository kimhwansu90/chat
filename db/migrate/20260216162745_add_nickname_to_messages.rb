class AddNicknameToMessages < ActiveRecord::Migration[8.1]
  def change
    add_column :messages, :nickname, :string
  end
end
