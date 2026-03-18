class EnhanceFormsAndFields < ActiveRecord::Migration[8.1]
  def change
    add_column :forms, :privacy_policy_text, :text
    add_column :forms, :submit_button_text, :string, default: "상담문의"

    add_column :form_fields, :placeholder, :string
    add_column :form_fields, :half_width, :boolean, default: false, null: false
    add_column :form_fields, :subtitle, :text
  end
end
