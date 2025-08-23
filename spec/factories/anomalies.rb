FactoryBot.define do
  factory :anomaly do
    txn { association :transaction }
    anomaly_type { 'MissingData' }
    reason { 'Missing required field(s): description' }
  end
end
