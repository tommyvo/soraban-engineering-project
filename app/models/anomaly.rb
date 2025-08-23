class Anomaly < ApplicationRecord
  # Use :txn instead of :transaction to avoid conflict with ActiveRecord's built-in transaction method
  belongs_to :txn, class_name: 'Transaction', foreign_key: 'transaction_id'
  validates :anomaly_type, presence: true
  validates :reason, presence: true
end
