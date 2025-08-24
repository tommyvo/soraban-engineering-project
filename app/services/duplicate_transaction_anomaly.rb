class DuplicateTransactionAnomaly
  ANOMALY_TYPE = 'DuplicateTransaction'.freeze

  def self.call(transaction)
    return nil if transaction.id.nil? # not persisted yet
    dup = Transaction.where(description: transaction.description, amount: transaction.amount, category: transaction.category, date: transaction.date)
                     .where.not(id: transaction.id)
                     .exists?
    if dup
      {
        anomaly_type: ANOMALY_TYPE,
        reason: "Possible duplicate transaction detected with same description, amount, category, and date."
      }
    else
      nil
    end
  end
end
