class CreateLeadActivities < ActiveRecord::Migration[8.1]
  def change
    create_table :lead_activities do |t|
      t.references :lead, null: false, foreign_key: true
      t.references :user, foreign_key: true
      t.string :activity_type, null: false
      t.text :content
      t.jsonb :metadata, default: {}

      t.timestamps
    end

    add_index :lead_activities, [:lead_id, :created_at]
  end
end
