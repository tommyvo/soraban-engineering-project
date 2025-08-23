require 'rails_helper'

RSpec.describe Transaction, type: :model do
  describe 'auto-categorization' do
    let!(:rule) { create(:rule, field: 'description', operator: 'contains', value: 'coffee', category: 'Food', priority: 1) }

    it 'assigns category if a rule matches, even if category is set' do
      tx = Transaction.create!(description: 'Starbucks coffee', amount: 5.0, date: Date.today, category: 'Drinks')
      expect(tx.category).to eq('Food')
    end

    it 'assigns category if blank and rule matches' do
      tx = Transaction.create!(description: 'Starbucks coffee', amount: 5.0, date: Date.today, category: nil)
      expect(tx.category).to eq('Food')
    end

    it 'does not auto-categorize on update' do
      tx = Transaction.create!(description: 'Starbucks coffee', amount: 5.0, date: Date.today, category: nil)
      tx.update!(description: 'Groceries', category: 'Other')
      expect(tx.category).to eq('Other')
    end
  end

  describe 'anomaly detection' do
    it 'creates a MissingData anomaly if required fields are missing' do
      tx = Transaction.create(description: nil, amount: nil, date: nil, category: nil)
      expect(tx.anomalies.count).to eq(1)
      anomaly = tx.anomalies.first
      expect(anomaly.anomaly_type).to eq('MissingData')
      expect(anomaly.reason).to match(/description/)
      expect(anomaly.reason).to match(/amount/)
      expect(anomaly.reason).to match(/date/)
    end

    it 'does not create anomalies if all required fields are present' do
      tx = Transaction.create(description: 'desc', amount: 1, date: Date.today, category: 'cat')
      expect(tx.anomalies).to be_empty
    end

    it 'replaces anomalies on update' do
      tx = Transaction.create(description: nil, amount: nil, date: nil, category: nil)
      expect(tx.anomalies.count).to eq(1)
      tx.update(description: 'desc', amount: 1, date: Date.today, category: 'cat')
      expect(tx.anomalies).to be_empty
    end
  end
end
