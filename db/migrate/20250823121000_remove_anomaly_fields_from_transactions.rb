class RemoveAnomalyFieldsFromTransactions < ActiveRecord::Migration[7.1]
  def change
    remove_column :transactions, :anomaly, :boolean
    remove_column :transactions, :anomaly_reason, :string
  end
end
