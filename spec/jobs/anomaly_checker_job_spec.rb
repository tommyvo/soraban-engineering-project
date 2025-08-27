require 'rails_helper'

describe AnomalyCheckerJob, type: :job do
  let(:transaction) { create(:transaction, description: nil, amount: nil, date: nil, category: nil) }

  it 'creates anomalies and sets approval fields' do
    expect {
      described_class.perform_now(transaction.id)
      transaction.reload
    }.to change { transaction.anomalies.count }.from(0).to(1)
    expect(transaction.approved).to eq(false)
    expect(transaction.anomalies.first.anomaly_type).to eq('MissingData')
  end

  it 'auto-approves if no anomalies' do
    tx = create(:transaction, description: 'desc', amount: 1, date: Date.today, category: 'cat')
    described_class.perform_now(tx.id)
    tx.reload
    expect(tx.anomalies).to be_empty
    expect(tx.approved).to eq(true)
    expect(tx.reviewed_by).to eq('system')
  end

  it 'does nothing if transaction does not exist' do
    expect {
      described_class.perform_now(-1)
    }.not_to raise_error
  end
end
