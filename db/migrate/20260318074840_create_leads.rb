class CreateLeads < ActiveRecord::Migration[8.1]
  def change
    create_table :leads do |t|
      t.string :name, null: false
      t.string :phone
      t.string :email
      t.string :status, null: false, default: "new"
      t.references :form, foreign_key: true
      t.references :assigned_to, foreign_key: { to_table: :users }
      t.string :utm_source
      t.string :utm_medium
      t.string :utm_campaign
      t.string :utm_content
      t.string :utm_term
      t.string :referrer_url
      t.string :landing_page_url
      t.string :ip_address
      t.jsonb :custom_fields, default: {}

      t.timestamps
    end

    add_index :leads, :status
    add_index :leads, :utm_source
    add_index :leads, :created_at
    add_index :leads, [:assigned_to_id, :status]
  end
end
