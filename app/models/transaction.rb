class Transaction < ApplicationRecord
  has_many :anomalies, dependent: :destroy, foreign_key: 'transaction_id', inverse_of: :txn

  validates :amount, numericality: true, allow_nil: true

  after_commit :enqueue_auto_categorize_job, on: :create
  after_commit :enqueue_anomaly_checker_job, on: [:create, :update]

  private

  def enqueue_auto_categorize_job
    AutoCategorizeTransactionJob.perform_later(self.id)
  end

  def enqueue_anomaly_checker_job
    AnomalyCheckerJob.perform_later(self.id)
  end
end
