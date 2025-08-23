class AddAnomalyFieldsToTransactions < ActiveRecord::Migration[7.1]
  def change
    add_column :transactions, :anomaly, :boolean, default: false, null: false
    add_column :transactions, :anomaly_reason, :string
  end
end
