class CreateForms < ActiveRecord::Migration[8.1]
  def change
    create_table :forms do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.string :redirect_url
      t.string :thank_you_message, default: "문의가 접수되었습니다."
      t.boolean :active, default: true, null: false
      t.references :created_by, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :forms, :slug, unique: true
  end
end
