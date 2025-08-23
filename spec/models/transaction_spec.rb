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
end
