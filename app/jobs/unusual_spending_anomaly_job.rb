class UnusualSpendingAnomalyJob < ApplicationJob
  queue_as :default

  def perform(transaction_id)
    transaction = Transaction.find_by(id: transaction_id)
    return unless transaction

    result = UnusualSpendingAnomaly.call(transaction)
    transaction.anomalies.where(anomaly_type: 'UnusualSpending').destroy_all
    if result
      transaction.anomalies.create!(anomaly_type: result[:anomaly_type], reason: result[:reason])
    end
  end
end
