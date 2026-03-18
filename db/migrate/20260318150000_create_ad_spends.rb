class CreateAdSpends < ActiveRecord::Migration[8.1]
  def change
    create_table :ad_spends do |t|
      t.string :channel, null: false          # naver / meta / 기타
      t.string :campaign_name, null: false    # UTM 캠페인명과 매핑
      t.bigint :amount, null: false, default: 0  # 광고비 (원)
      t.date   :period_start, null: false
      t.date   :period_end,   null: false
      t.text   :memo
      t.references :created_by, foreign_key: { to_table: :users }, null: true

      t.timestamps
    end

    add_index :ad_spends, [:period_start, :period_end]
    add_index :ad_spends, :channel
  end
end
