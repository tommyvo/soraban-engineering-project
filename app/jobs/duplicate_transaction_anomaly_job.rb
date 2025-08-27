class DuplicateTransactionAnomalyJob < ApplicationJob
  queue_as :default

  def perform(transaction_id)
    transaction = Transaction.find_by(id: transaction_id)
    return unless transaction

    result = DuplicateTransactionAnomaly.call(transaction)
    transaction.anomalies.where(anomaly_type: 'DuplicateTransaction').destroy_all
    if result
      transaction.anomalies.create!(anomaly_type: result[:anomaly_type], reason: result[:reason])
    end
  end
end
