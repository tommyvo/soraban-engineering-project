require 'rails_helper'

describe DuplicateTransactionAnomaly do
  let!(:tx1) { Transaction.create!(description: 'Coffee', amount: 3.50, category: 'Food', date: Date.today) }
  let!(:tx2) { Transaction.create!(description: 'Coffee', amount: 3.50, category: 'Food', date: Date.today) }

  it 'flags a duplicate transaction' do
    result = described_class.call(tx2)
    expect(result).to be_a(Hash)
    expect(result[:anomaly_type]).to eq('DuplicateTransaction')
    expect(result[:reason]).to match(/duplicate/i)
  end

  it 'does not flag a unique transaction' do
    unique_tx = Transaction.create!(description: 'Groceries', amount: 20.00, category: 'Food', date: Date.today)
    result = described_class.call(unique_tx)
    expect(result).to be_nil
  end
end
