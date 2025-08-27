require 'rails_helper'

RSpec.describe Transaction, type: :model do
  describe 'auto-categorization' do
    let!(:rule) { create(:rule, field: 'description', operator: 'contains', value: 'coffee', category: 'Food', priority: 1) }

    it 'assigns category if a rule matches, even if category is set' do
      tx = nil
      perform_enqueued_jobs do
        tx = create(:transaction, description: 'Starbucks coffee', amount: 5.0, date: Date.today, category: 'Drinks')
      end
      tx.reload
      expect(tx.category).to eq('Food') # Should always override with rule
    end

    it 'does not match if case is different' do
      tx = nil
      perform_enqueued_jobs do
        tx = create(:transaction, description: 'Starbucks Coffee', amount: 5.0, date: Date.today, category: 'Drinks')
      end
      tx.reload
      expect(tx.category).to eq('Drinks')
    end

    it 'assigns category if blank and rule matches' do
      tx = nil
      perform_enqueued_jobs do
        tx = create(:transaction, description: 'Starbucks coffee', amount: 5.0, date: Date.today, category: nil)
      end
      tx.reload
      expect(tx.category).to eq('Food')
    end

    it 'does not auto-categorize on update' do
      tx = nil
      perform_enqueued_jobs do
        tx = create(:transaction, description: 'Starbucks coffee', amount: 5.0, date: Date.today, category: nil)
      end
      tx.update!(description: 'Groceries', category: 'Other')
      tx.reload
      expect(tx.category).to eq('Other')
    end
  end

  describe 'anomaly detection' do
    it 'does not overwrite user approval on update or anomaly check' do
      perform_enqueued_jobs do
        tx = create(:transaction, description: nil, amount: nil, date: nil, category: nil)
        expect(tx.anomalies.count).to eq(1)
        expect(tx.approved).to eq(false)

        # Simulate user approval
        user_time = 2.days.from_now
        tx.update_columns(approved: true, approved_at: user_time, reviewed_by: 'user')

        # Update transaction to trigger anomaly check
        tx.update(description: 'desc')
        tx.reload
        expect(tx.approved).to eq(true)
        expect(tx.approved_at.to_i).to eq(user_time.to_i)
        expect(tx.reviewed_by).to eq('user')

        # Even if anomalies are present again, approval is not reset
        tx.update(description: nil)
        tx.reload
        expect(tx.approved).to eq(true)
        expect(tx.reviewed_by).to eq('user')
      end
    end

    it 'creates a MissingData anomaly if required fields are missing and does not approve' do
      perform_enqueued_jobs do
        tx = create(:transaction, description: nil, amount: nil, date: nil, category: nil)
        expect(tx.anomalies.count).to eq(1)

        anomaly = tx.anomalies.first
        expect(anomaly.anomaly_type).to eq('MissingData')
        expect(anomaly.reason).to match(/description/)
        expect(anomaly.reason).to match(/amount/)
        expect(anomaly.reason).to match(/date/)
        expect(tx.approved).to eq(false)
        expect(tx.approved_at).to be_nil
        expect(tx.reviewed_by).to be_nil
      end
    end

    it 'does not create anomalies if all required fields are present and is auto-approved' do
      tx = nil
      perform_enqueued_jobs do
        tx = create(:transaction, description: 'desc', amount: 1, date: Date.today, category: 'cat')
      end
      tx.reload
      expect(tx.anomalies).to be_empty
      expect(tx.approved).to eq(true)
      expect(tx.approved_at).not_to be_nil
      expect(tx.reviewed_by).to eq('system')
    end

    it 'replaces anomalies on update and auto-approves if fixed' do
      tx = nil
      perform_enqueued_jobs do
        tx = create(:transaction, description: nil, amount: nil, date: nil, category: nil)
        expect(tx.anomalies.count).to eq(1)
        expect(tx.approved).to eq(false)

        tx.update(description: 'desc', amount: 1, date: Date.today, category: 'cat')
      end
      tx.reload
      expect(tx.anomalies).to be_empty
      expect(tx.approved).to eq(true)
      expect(tx.approved_at).not_to be_nil
      expect(tx.reviewed_by).to eq('system')
    end
  end
end
