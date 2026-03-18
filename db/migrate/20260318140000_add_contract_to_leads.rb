class AddContractToLeads < ActiveRecord::Migration[8.1]
  def change
    add_column :leads, :contract_value, :bigint, default: 0
    add_column :leads, :contracted_at, :datetime
    add_index :leads, :contracted_at
  end
end
