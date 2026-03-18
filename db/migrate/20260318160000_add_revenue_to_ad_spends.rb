class AddRevenueToAdSpends < ActiveRecord::Migration[8.0]
  def change
    add_column :ad_spends, :revenue, :bigint, default: 0, null: false
  end
end
