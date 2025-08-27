class AnomalyCheckerJob < ApplicationJob
  queue_as :default

  def perform(transaction_id)
    transaction = Transaction.find_by(id: transaction_id)
    return unless transaction

    transaction.anomalies.destroy_all

    anomalies = []
    [
      DuplicateTransactionAnomaly,
      MissingDataAnomaly,
      UnusualSpendingAnomaly
    ].each do |klass|
      result = klass.call(transaction)
      anomalies << result if result.present?
    end

    anomalies.each do |anomaly|
      transaction.anomalies.create!(anomaly_type: anomaly[:anomaly_type], reason: anomaly[:reason])
    end

    if anomalies.empty?
      unless transaction.approved && transaction.reviewed_by == "user"
        transaction.update_columns(approved: true, approved_at: transaction.created_at || Time.current, reviewed_by: "system")
      end
    else
      unless transaction.approved && transaction.reviewed_by == "user"
        transaction.update_columns(approved: false, approved_at: nil, reviewed_by: nil)
      end
    end
  end
end
