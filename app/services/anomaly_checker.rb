class AnomalyChecker
  CHECKS = [
    'DuplicateTransactionAnomaly',
    'MissingDataAnomaly',
    'UnusualSpendingAnomaly'
  ]

  def self.call(transaction)
    results = CHECKS.map do |klass|
      klass.constantize.call(transaction)
    end.compact
    results.select { |r| r[:anomaly_type].present? }
  end
end
