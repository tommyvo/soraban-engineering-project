require 'rails_helper'

describe MissingDataAnomaly do
  it 'returns anomaly: false if all required fields are present' do
    valid_transaction = build(:transaction, description: 'Lunch', amount: 10.0, date: Date.today, category: 'Food')
    result = described_class.call(valid_transaction)
    expect(result).to eq(nil)
  end

  it 'detects missing description' do
    tx = build(:transaction, description: nil)
    result = described_class.call(tx)
    expect(result[:reason]).to match(/description/)
  end

  it 'detects missing amount' do
    tx = build(:transaction, amount: nil)
    result = described_class.call(tx)
    expect(result[:reason]).to match(/amount/)
  end

  it 'detects multiple missing fields' do
    tx = build(:transaction, description: nil, amount: nil, date: nil)
    result = described_class.call(tx)
    expect(result[:reason]).to match(/description/)
    expect(result[:reason]).to match(/amount/)
    expect(result[:reason]).to match(/date/)
  end
end
