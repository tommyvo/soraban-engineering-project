require "action_cable/engine"
class Transaction < ApplicationRecord
  has_many :anomalies, dependent: :destroy, foreign_key: "transaction_id", inverse_of: :txn

  validates :amount, numericality: true, allow_nil: true

  after_commit :enqueue_auto_categorize_job, on: :create
  after_commit :enqueue_anomaly_checker_job, on: [ :create, :update ]

  unless Rails.env.test?
    after_commit :broadcast_create, on: :create
    after_commit :broadcast_update, on: :update
    after_commit :broadcast_destroy, on: :destroy
  end

  # Batch broadcast suppression helpers
  def self.suppress_broadcasts
    Thread.current[:suppress_transaction_broadcasts] = true
    yield
  ensure
    Thread.current[:suppress_transaction_broadcasts] = false
  end

  def self.broadcasts_suppressed?
    Thread.current[:suppress_transaction_broadcasts]
  end

  def broadcast_create
    return if Rails.env.test? || Transaction.broadcasts_suppressed?
    ::ActionCable.server.broadcast("transactions", { action: "created", transaction: self.as_json })
  end

  def broadcast_update
    return if Rails.env.test? || Transaction.broadcasts_suppressed?
    ::ActionCable.server.broadcast("transactions", { action: "updated", transaction: self.as_json })
  end

  def broadcast_destroy
    return if Rails.env.test? || Transaction.broadcasts_suppressed?
    ::ActionCable.server.broadcast("transactions", { action: "destroyed", id: self.id })
  end

  private

  def enqueue_auto_categorize_job
    AutoCategorizeTransactionJob.perform_later(self.id)
  end

  def enqueue_anomaly_checker_job
    AnomalyCheckerJob.perform_later(self.id)
  end
end
