require 'rails_helper'

describe UnusualSpendingAnomaly do
  before do
    [10, 12, 13, 15, 16, 18, 20, 22, 25, 30].each do |amt|
      create(:transaction, description: 'Test', amount: amt, category: 'Food', date: Date.today - rand(1..89))
    end
    # Add some transactions in a different category to ensure they are not included
    [100, 200, 300].each do |amt|
      create(:transaction, description: 'Other Category', amount: amt, category: 'Travel', date: Date.today - rand(1..89))
    end
  end

  it 'flags a transaction as unusual if amount is above the upper bound' do
    tx = create(:transaction, description: 'Big Spend', amount: 100, category: 'Food', date: Date.today)
    result = described_class.call(tx)
    expect(result).to be_a(Hash)
    expect(result[:anomaly_type]).to eq('UnusualSpending')
    expect(result[:reason]).to match(/unusual|high/i)
  end

  it 'does not consider transactions from other categories' do
    tx = create(:transaction, description: 'Big Spend Travel', amount: 400, category: 'Travel', date: Date.today)
    result = described_class.call(tx)
    # Should not be flagged as unusual because only 3 "Travel" transactions exist (less than MIN_NUMBER_OF_AMOUNTS)
    expect(result).to be_nil
  end

  it 'does not flag a transaction within the normal range' do
    tx = create(:transaction, description: 'Normal Spend', amount: 15, category: 'Food', date: Date.today)
    result = described_class.call(tx)
    expect(result).to be_nil
  end
end
