class AnomalyChecker
  CHECKS = [
    'DuplicateTransactionAnomaly',
    'MissingDataAnomaly',
    'UnusualSpendingAnomaly'
  ]

  def self.call(transaction)
    CHECKS.each do |klass|
      result = klass.constantize.call(transaction)
      return result if result&.dig(:anomaly)
    end
    { anomaly: false }
  end
end
