class CreateFormFields < ActiveRecord::Migration[8.1]
  def change
    create_table :form_fields do |t|
      t.references :form, null: false, foreign_key: true
      t.string :label, null: false
      t.string :field_type, null: false, default: "text"
      t.string :name, null: false
      t.boolean :required, default: false, null: false
      t.text :options
      t.integer :position, default: 0, null: false

      t.timestamps
    end

    add_index :form_fields, [:form_id, :position]
  end
end
