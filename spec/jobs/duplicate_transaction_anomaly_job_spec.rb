require 'rails_helper'

describe DuplicateTransactionAnomalyJob, type: :job do
  let(:transaction) { instance_double(Transaction, id: 42, anomalies: anomalies) }
  let(:anomalies) { double('anomalies') }

  before do
    allow(Transaction).to receive(:find_by).with(id: 42).and_return(transaction)
    allow(Transaction).to receive(:find_by).with(id: -1).and_return(nil)
    allow(anomalies).to receive(:where).with(anomaly_type: 'DuplicateTransaction').and_return(anomalies)
    allow(anomalies).to receive(:destroy_all)
  end

  it 'calls the service and creates an anomaly if result is present' do
    result = { anomaly_type: 'DuplicateTransaction', reason: 'dup' }
    expect(DuplicateTransactionAnomaly).to receive(:call).with(transaction).and_return(result)
    expect(anomalies).to receive(:create!).with(anomaly_type: 'DuplicateTransaction', reason: 'dup')
    described_class.perform_now(42)
  end

  it 'calls the service and does not create an anomaly if result is nil' do
    expect(DuplicateTransactionAnomaly).to receive(:call).with(transaction).and_return(nil)
    expect(anomalies).not_to receive(:create!)
    described_class.perform_now(42)
  end

  it 'does nothing if transaction does not exist' do
    expect(DuplicateTransactionAnomaly).not_to receive(:call)
    expect {
      described_class.perform_now(-1)
    }.not_to raise_error
  end
end
