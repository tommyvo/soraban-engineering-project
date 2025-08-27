class Transaction < ApplicationRecord
  has_many :anomalies, dependent: :destroy, foreign_key: 'transaction_id', inverse_of: :txn

  validates :amount, numericality: true, allow_nil: true

  before_validation :auto_categorize, on: :create
  after_commit :enqueue_anomaly_checker_job, on: [:create, :update]

  private

  def auto_categorize
    matched = RuleService.categorize(self)
    self.category = matched if matched.present?
  end

  def enqueue_anomaly_checker_job
    AnomalyCheckerJob.perform_later(self.id)
  end
end
