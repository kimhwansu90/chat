class CreateNadAccounts < ActiveRecord::Migration[8.1]
  def change
    create_table :nad_accounts do |t|
      t.string :name, null: false
      t.string :customer_id, null: false
      t.string :encrypted_api_key
      t.string :encrypted_api_key_iv
      t.string :encrypted_api_secret
      t.string :encrypted_api_secret_iv
      t.boolean :active, default: true, null: false
      t.datetime :last_synced_at

      t.timestamps
    end

    create_table :nad_campaigns do |t|
      t.references :nad_account, null: false, foreign_key: true
      t.string :external_id, null: false
      t.string :name, null: false
      t.string :campaign_type
      t.string :status
      t.bigint :budget
      t.datetime :synced_at

      t.timestamps
    end
    add_index :nad_campaigns, [ :nad_account_id, :external_id ], unique: true

    create_table :nad_ad_groups do |t|
      t.references :nad_campaign, null: false, foreign_key: true
      t.string :external_id, null: false
      t.string :name, null: false
      t.string :status
      t.datetime :synced_at

      t.timestamps
    end
    add_index :nad_ad_groups, [ :nad_campaign_id, :external_id ], unique: true

    create_table :nad_keywords do |t|
      t.references :nad_ad_group, null: false, foreign_key: true
      t.string :external_id, null: false
      t.string :keyword, null: false
      t.string :match_type
      t.string :status
      t.bigint :bid_amount
      t.datetime :synced_at

      t.timestamps
    end
    add_index :nad_keywords, [ :nad_ad_group_id, :external_id ], unique: true

    create_table :nad_reports do |t|
      t.references :nad_account, null: false, foreign_key: true
      t.string :report_type, null: false
      t.string :entity_id
      t.date :report_date, null: false
      t.bigint :impressions, default: 0
      t.bigint :clicks, default: 0
      t.bigint :conversions, default: 0
      t.bigint :cost, default: 0
      t.bigint :revenue, default: 0

      t.timestamps
    end
    add_index :nad_reports, [ :nad_account_id, :report_type, :entity_id, :report_date ], unique: true, name: "idx_nad_reports_unique"
  end
end
