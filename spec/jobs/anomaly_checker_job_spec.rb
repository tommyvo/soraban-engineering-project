require 'rails_helper'

describe AnomalyCheckerJob, type: :job do
  let(:transaction) { instance_double(Transaction, id: 42) }

  before do
    allow(Transaction).to receive(:find_by).with(id: 42).and_return(transaction)
    allow(Transaction).to receive(:find_by).with(id: -1).and_return(nil)
  end

  it 'enqueues all anomaly jobs for the transaction' do
    expect(DuplicateTransactionAnomalyJob).to receive(:perform_later).with(42)
    expect(MissingDataAnomalyJob).to receive(:perform_later).with(42)
    expect(UnusualSpendingAnomalyJob).to receive(:perform_later).with(42)
    described_class.perform_now(42)
  end

  it 'does nothing if transaction does not exist' do
    expect(DuplicateTransactionAnomalyJob).not_to receive(:perform_later)
    expect(MissingDataAnomalyJob).not_to receive(:perform_later)
    expect(UnusualSpendingAnomalyJob).not_to receive(:perform_later)
    expect {
      described_class.perform_now(-1)
    }.not_to raise_error
  end
end
