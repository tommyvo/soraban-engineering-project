require 'rails_helper'

describe AnomalyChecker do
  let(:transaction) { build(:transaction) }

  before do
    stub_const('DuplicateTransactionAnomaly', Class.new do
      def self.call(_tx)
        nil
      end
    end)
    stub_const('MissingDataAnomaly', Class.new do
      def self.call(_tx)
        nil
      end
    end)
    stub_const('UnusualSpendingAnomaly', Class.new do
      def self.call(_tx)
        nil
      end
    end)
  end

  it 'returns anomaly: false if no checks flag an anomaly' do
    expect(described_class.call(transaction)).to eq(anomaly: false)
  end

  it 'returns the first anomaly found' do
    allow(DuplicateTransactionAnomaly).to receive(:call).and_return(nil)
    allow(MissingDataAnomaly).to receive(:call).and_return({ anomaly: true, reason: 'Missing data' })
    allow(UnusualSpendingAnomaly).to receive(:call).and_return({ anomaly: true, reason: 'Unusual spending' })

    result = described_class.call(transaction)
    expect(result).to eq(anomaly: true, reason: 'Missing data')
  end

  it 'short-circuits after the first anomaly' do
    expect(DuplicateTransactionAnomaly).to receive(:call).once.and_return({ anomaly: true, reason: 'Duplicate' })
    expect(MissingDataAnomaly).not_to receive(:call)
    expect(UnusualSpendingAnomaly).not_to receive(:call)
    result = described_class.call(transaction)
    expect(result).to eq(anomaly: true, reason: 'Duplicate')
  end
end
