class MissingDataAnomaly
  REQUIRED_FIELDS = %w[description amount date category]
  ANOMALY_TYPE = "MissingData".freeze

  def self.call(transaction)
    missing = REQUIRED_FIELDS.select { |field| transaction.send(field).blank? }

    if missing.any?
      {
        anomaly_type: ANOMALY_TYPE,
        reason: "Missing required field(s): #{missing.join(', ')}"
      }
    else
      nil
    end
  end
end
