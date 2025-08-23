class RemoveMetadataFromTransactions < ActiveRecord::Migration[7.1]
  def change
    remove_column :transactions, :metadata, :jsonb
  end
end
