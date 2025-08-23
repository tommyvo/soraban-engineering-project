class Transaction < ApplicationRecord
  has_many :anomalies, dependent: :destroy, foreign_key: 'transaction_id', inverse_of: :txn

  validates :description, uniqueness: { scope: [:amount, :category, :date], message: "with this amount, category, and date already exists" }
  validates :amount, numericality: true, allow_nil: true

  before_validation :auto_categorize, on: :create
  after_commit :run_anomaly_checks, on: [:create, :update]

  private

  def auto_categorize
    matched = RuleService.categorize(self)
    self.category = matched if matched.present?
  end

  def run_anomaly_checks
    self.anomalies.destroy_all
    anomalies = AnomalyChecker.call(self)
    anomalies.each do |anomaly|
      self.anomalies.create!(anomaly_type: anomaly[:anomaly_type], reason: anomaly[:reason])
    end
  end
end
