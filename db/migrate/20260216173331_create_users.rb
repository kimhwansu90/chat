class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :username, null: false, index: { unique: true }
      t.string :nickname

      t.timestamps
    end
  end
end
