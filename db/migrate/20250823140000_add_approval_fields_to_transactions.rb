class AddApprovalFieldsToTransactions < ActiveRecord::Migration[7.1]
  def change
    add_column :transactions, :approved, :boolean, default: false, null: false
    add_column :transactions, :approved_at, :datetime
    add_column :transactions, :reviewed_by, :string
  end
end
