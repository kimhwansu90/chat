# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_03_18_080325) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "form_fields", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "field_type", default: "text", null: false
    t.bigint "form_id", null: false
    t.string "label", null: false
    t.string "name", null: false
    t.text "options"
    t.integer "position", default: 0, null: false
    t.boolean "required", default: false, null: false
    t.datetime "updated_at", null: false
    t.index ["form_id", "position"], name: "index_form_fields_on_form_id_and_position"
    t.index ["form_id"], name: "index_form_fields_on_form_id"
  end

  create_table "forms", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.bigint "created_by_id"
    t.text "description"
    t.string "name", null: false
    t.string "redirect_url"
    t.string "slug", null: false
    t.string "thank_you_message", default: "문의가 접수되었습니다."
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_forms_on_created_by_id"
    t.index ["slug"], name: "index_forms_on_slug", unique: true
  end

  create_table "lead_activities", force: :cascade do |t|
    t.string "activity_type", null: false
    t.text "content"
    t.datetime "created_at", null: false
    t.bigint "lead_id", null: false
    t.jsonb "metadata", default: {}
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["lead_id", "created_at"], name: "index_lead_activities_on_lead_id_and_created_at"
    t.index ["lead_id"], name: "index_lead_activities_on_lead_id"
    t.index ["user_id"], name: "index_lead_activities_on_user_id"
  end

  create_table "leads", force: :cascade do |t|
    t.bigint "assigned_to_id"
    t.datetime "created_at", null: false
    t.jsonb "custom_fields", default: {}
    t.string "email"
    t.bigint "form_id"
    t.string "ip_address"
    t.string "landing_page_url"
    t.string "name", null: false
    t.string "phone"
    t.string "referrer_url"
    t.string "status", default: "new", null: false
    t.datetime "updated_at", null: false
    t.string "utm_campaign"
    t.string "utm_content"
    t.string "utm_medium"
    t.string "utm_source"
    t.string "utm_term"
    t.index ["assigned_to_id", "status"], name: "index_leads_on_assigned_to_id_and_status"
    t.index ["assigned_to_id"], name: "index_leads_on_assigned_to_id"
    t.index ["created_at"], name: "index_leads_on_created_at"
    t.index ["form_id"], name: "index_leads_on_form_id"
    t.index ["status"], name: "index_leads_on_status"
    t.index ["utm_source"], name: "index_leads_on_utm_source"
  end

  create_table "nad_accounts", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.string "customer_id", null: false
    t.string "encrypted_api_key"
    t.string "encrypted_api_key_iv"
    t.string "encrypted_api_secret"
    t.string "encrypted_api_secret_iv"
    t.datetime "last_synced_at"
    t.string "name", null: false
    t.datetime "updated_at", null: false
  end

  create_table "nad_ad_groups", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "external_id", null: false
    t.bigint "nad_campaign_id", null: false
    t.string "name", null: false
    t.string "status"
    t.datetime "synced_at"
    t.datetime "updated_at", null: false
    t.index ["nad_campaign_id", "external_id"], name: "index_nad_ad_groups_on_nad_campaign_id_and_external_id", unique: true
    t.index ["nad_campaign_id"], name: "index_nad_ad_groups_on_nad_campaign_id"
  end

  create_table "nad_campaigns", force: :cascade do |t|
    t.bigint "budget"
    t.string "campaign_type"
    t.datetime "created_at", null: false
    t.string "external_id", null: false
    t.bigint "nad_account_id", null: false
    t.string "name", null: false
    t.string "status"
    t.datetime "synced_at"
    t.datetime "updated_at", null: false
    t.index ["nad_account_id", "external_id"], name: "index_nad_campaigns_on_nad_account_id_and_external_id", unique: true
    t.index ["nad_account_id"], name: "index_nad_campaigns_on_nad_account_id"
  end

  create_table "nad_keywords", force: :cascade do |t|
    t.bigint "bid_amount"
    t.datetime "created_at", null: false
    t.string "external_id", null: false
    t.string "keyword", null: false
    t.string "match_type"
    t.bigint "nad_ad_group_id", null: false
    t.string "status"
    t.datetime "synced_at"
    t.datetime "updated_at", null: false
    t.index ["nad_ad_group_id", "external_id"], name: "index_nad_keywords_on_nad_ad_group_id_and_external_id", unique: true
    t.index ["nad_ad_group_id"], name: "index_nad_keywords_on_nad_ad_group_id"
  end

  create_table "nad_reports", force: :cascade do |t|
    t.bigint "clicks", default: 0
    t.bigint "conversions", default: 0
    t.bigint "cost", default: 0
    t.datetime "created_at", null: false
    t.string "entity_id"
    t.bigint "impressions", default: 0
    t.bigint "nad_account_id", null: false
    t.date "report_date", null: false
    t.string "report_type", null: false
    t.bigint "revenue", default: 0
    t.datetime "updated_at", null: false
    t.index ["nad_account_id", "report_type", "entity_id", "report_date"], name: "idx_nad_reports_unique", unique: true
    t.index ["nad_account_id"], name: "index_nad_reports_on_nad_account_id"
  end

  create_table "users", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.boolean "banned", default: false
    t.datetime "banned_at"
    t.string "banned_reason"
    t.datetime "created_at", null: false
    t.string "email"
    t.datetime "last_seen_at"
    t.string "nickname"
    t.string "password_digest"
    t.string "phone"
    t.string "role", default: "sales_rep"
    t.datetime "updated_at", null: false
    t.string "username", null: false
    t.index ["email"], name: "index_users_on_email", unique: true, where: "(email IS NOT NULL)"
    t.index ["role"], name: "index_users_on_role"
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "form_fields", "forms"
  add_foreign_key "forms", "users", column: "created_by_id"
  add_foreign_key "lead_activities", "leads"
  add_foreign_key "lead_activities", "users"
  add_foreign_key "leads", "forms"
  add_foreign_key "leads", "users", column: "assigned_to_id"
  add_foreign_key "nad_ad_groups", "nad_campaigns"
  add_foreign_key "nad_campaigns", "nad_accounts"
  add_foreign_key "nad_keywords", "nad_ad_groups"
  add_foreign_key "nad_reports", "nad_accounts"
end
