require 'rails_helper'

describe Anomaly, type: :model do
  let(:transaction) { Transaction.create!(description: 'desc', amount: 1, date: Date.today, category: 'cat') }

  it 'belongs to txn' do
    anomaly = Anomaly.new(txn: transaction, anomaly_type: 'Test', reason: 'Test reason')
    expect(anomaly.txn).to eq(transaction)
  end

  it 'is invalid without anomaly_type' do
    anomaly = Anomaly.new(txn: transaction, anomaly_type: nil, reason: 'Test reason')
    expect(anomaly).not_to be_valid
    expect(anomaly.errors[:anomaly_type]).to be_present
  end

  it 'is invalid without reason' do
    anomaly = Anomaly.new(txn: transaction, anomaly_type: 'Test', reason: nil)
    expect(anomaly).not_to be_valid
    expect(anomaly.errors[:reason]).to be_present
  end
end
