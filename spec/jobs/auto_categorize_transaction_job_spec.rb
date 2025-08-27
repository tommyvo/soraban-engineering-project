require 'rails_helper'

RSpec.describe AutoCategorizeTransactionJob, type: :job do
  let!(:rule) { create(:rule, field: 'description', operator: 'contains', value: 'coffee', category: 'Food', priority: 1) }

  it 'overrides the category with the rule match (case-sensitive)' do
    tx = create(:transaction, description: 'Starbucks coffee', amount: 5.0, date: Date.today, category: 'Drinks')
    expect(tx.category).to eq('Drinks')
    described_class.perform_now(tx.id)
    tx.reload
    expect(tx.category).to eq('Food')
  end

  it 'does not match if case is different' do
    tx = create(:transaction, description: 'Starbucks Coffee', amount: 5.0, date: Date.today, category: 'Drinks')
    expect(tx.category).to eq('Drinks')
    described_class.perform_now(tx.id)
    tx.reload
    expect(tx.category).to eq('Drinks')
  end

  it 'does nothing if no rule matches' do
    tx = create(:transaction, description: 'Groceries', amount: 20.0, date: Date.today, category: 'Other')
    expect(tx.category).to eq('Other')
    described_class.perform_now(tx.id)
    tx.reload
    expect(tx.category).to eq('Other')
  end

  it 'does nothing if transaction does not exist' do
    expect { described_class.perform_now(-1) }.not_to raise_error
  end
end
