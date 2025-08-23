require 'rails_helper'

describe RuleService do
  let(:transaction) { create(:transaction, description: desc, amount: amt) }

  context 'description contains' do
    let(:desc) { 'Starbucks coffee' }
    let(:amt) { 5.0 }
    let!(:rule) { create(:rule, field: 'description', operator: 'contains', value: 'coffee', category: 'Food', priority: 1) }

    it 'matches and returns the category' do
      expect(described_class.categorize(transaction)).to eq('Food')
    end
  end

  context 'amount >' do
    let(:desc) { 'Big purchase' }
    let(:amt) { 2000 }
    let!(:rule) { create(:rule, field: 'amount', operator: '>', value: '1000', category: 'High Value', priority: 1) }

    it 'matches and returns the category' do
      expect(described_class.categorize(transaction)).to eq('High Value')
    end
  end

  context 'multiple rules, priority' do
    let(:desc) { 'Big purchase' }
    let!(:low) { create(:rule, field: 'amount', operator: '>', value: '1000', category: 'High Value', priority: 2) }
    let!(:high) { create(:rule, field: 'amount', operator: '>', value: '5000', category: 'Very High Value', priority: 1) }

    context 'amount is 6000' do
      let(:amt) { 6000 }

      it 'returns the category of the highest priority rule' do
        expect(described_class.categorize(transaction)).to eq('Very High Value')
      end
    end

    context 'amount is 5000' do
      let(:amt) { 5000 }

      it 'returns the category of the second highest priority rule' do
        expect(described_class.categorize(transaction)).to eq('High Value')
      end
    end
  end

  context 'no match' do
    let(:desc) { 'Lunch' }
    let(:amt) { 10 }

    it 'returns nil if no rule matches' do
      expect(described_class.categorize(transaction)).to be_nil
    end
  end
end
