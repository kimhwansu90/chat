class CreateReports < ActiveRecord::Migration[8.1]
  def change
    create_table :reports do |t|
      t.string :reporter_username
      t.string :reported_username
      t.references :message, null: false, foreign_key: true
      t.string :report_type
      t.text :reason
      t.string :status, default: "pending"
      t.string :reviewed_by

      t.timestamps
    end
  end
end
