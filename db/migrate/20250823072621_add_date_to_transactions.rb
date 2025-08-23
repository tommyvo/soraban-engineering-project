class AddDateToTransactions < ActiveRecord::Migration[8.0]
  def change
    add_column :transactions, :date, :date
  end
end
