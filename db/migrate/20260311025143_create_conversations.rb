class CreateConversations < ActiveRecord::Migration[8.1]
  def change
    create_table :conversations do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.datetime :last_message_at, index: true
      t.integer :admin_unread_count, default: 0, null: false
      t.integer :user_unread_count, default: 0, null: false
      t.timestamps
    end
  end
end
