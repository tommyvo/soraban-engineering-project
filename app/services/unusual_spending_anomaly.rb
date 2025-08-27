class UnusualSpendingAnomaly
  ANOMALY_TYPE = "UnusualSpending".freeze
  ROLLING_WINDOW_DAYS = 90
  MIN_NUMBER_OF_AMOUNTS = 4

  # This multiplier can be adjusted if we expect to have many natural outliers.
  # You might want to increase the multiplier (e.g. 2 or 3) to reduce false positives.
  IQR_MULTIPLIER = 1.5

  def self.call(transaction)
    return nil if transaction.id.nil? || transaction.amount.nil? || transaction.category.blank?

    # Look at last 90 days, same category, excluding this transaction
    window_start = (transaction.date || Date.today) - ROLLING_WINDOW_DAYS
    txs = Transaction.where("date >= ? AND id != ? AND category = ?", window_start, transaction.id, transaction.category)
      .where.not(amount: nil)
    amounts = txs.pluck(:amount).map(&:to_f).sort

    # Not enough data for IQR, because you won't be able to reliably detect
    # outliers. Statistically, quartiles require at least 4 values to be
    # distinct and meaningful; with fewer, the concept of "middle 50%" or
    # "upper/lower quartile" doesn't make sense, and any threshold would be
    # arbitrary.
    return nil if amounts.size < MIN_NUMBER_OF_AMOUNTS

    q1 = percentile(amounts, 25)
    q3 = percentile(amounts, 75)
    iqr = q3 - q1
    upper = q3 + IQR_MULTIPLIER * iqr

    if transaction.amount > upper
      {
        anomaly_type: ANOMALY_TYPE,
        reason: "Transaction amount $#{transaction.amount} is unusually high for category '#{transaction.category}' (above $#{upper.round(2)} based on last 90 days)"
      }
    else
      nil
    end
  end

  # Helper: percentile using linear interpolation
  def self.percentile(sorted, pct)
    return nil if sorted.empty?
    rank = (pct / 100.0) * (sorted.length - 1)
    lower = sorted[rank.floor]
    upper = sorted[rank.ceil]
    lower + (upper - lower) * (rank - rank.floor)
  end
end
