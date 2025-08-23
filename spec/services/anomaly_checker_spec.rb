require 'rails_helper'

describe AnomalyChecker do
  let(:transaction) { build(:transaction) }

  # TODO: remove this as things get implemented
  before do
    stub_const('DuplicateTransactionAnomaly', Class.new do
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

  it 'returns an empty array if no checks flag an anomaly' do
    expect(described_class.call(transaction)).to eq([])
  end

  context 'transaction has missing data' do
    let(:transaction) { build(:transaction, description: nil) }

    it 'returns the payload for missing data' do
      result = described_class.call(transaction)
      expect(result).to eq([
        { anomaly_type: "MissingData", reason: "Missing required field(s): description" },
      ])
    end
  end
end
