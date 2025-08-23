require 'rails_helper'

RSpec.describe Rule, type: :model do
  subject { described_class.new(field: field, operator: operator, value: value, category: category, priority: priority) }

  let(:category) { 'TestCat' }
  let(:priority) { 1 }

  context 'validations' do
    context 'field and operator combinations' do
      it 'is valid for description/contains' do
        rule = described_class.new(field: 'description', operator: 'contains', value: 'coffee', category: category, priority: priority)
        expect(rule).to be_valid
      end

      it 'is invalid for description' do
        rule = described_class.new(field: 'description', operator: '>', value: 'coffee', category: category, priority: priority)
        expect(rule).not_to be_valid
        expect(rule.errors[:operator]).to include('must be "contains" when field is "description"')
      end

      it 'is valid for amount' do
        rule = described_class.new(field: 'amount', operator: '>', value: '1000', category: category, priority: priority)
        expect(rule).to be_valid
      end

      it 'is invalid for amount/contains' do
        rule = described_class.new(field: 'amount', operator: 'contains', value: '1000', category: category, priority: priority)
        expect(rule).not_to be_valid
        expect(rule.errors[:operator]).to include('must be one of >, <, = when field is "amount"')
      end
    end

    it 'is invalid for unknown field' do
      rule = described_class.new(field: 'foo', operator: 'contains', value: 'bar', category: category, priority: priority)
      expect(rule).not_to be_valid
      expect(rule.errors[:field]).to include('is not included in the list')
    end

    it 'is invalid for unknown operator' do
      rule = described_class.new(field: 'description', operator: 'foo', value: 'bar', category: category, priority: priority)
      expect(rule).not_to be_valid
      expect(rule.errors[:operator]).to include('is not included in the list')
    end

    it 'requires all fields' do
      rule = described_class.new
      expect(rule).not_to be_valid
      expect(rule.errors[:field]).to be_present
      expect(rule.errors[:operator]).to be_present
      expect(rule.errors[:value]).to be_present
      expect(rule.errors[:category]).to be_present
      expect(rule.errors[:priority]).to be_present
    end

    it 'enforces unique priority per field/operator' do
      described_class.create!(field: 'amount', operator: '>', value: '1000', category: category, priority: 1)
      dup = described_class.new(field: 'amount', operator: '>', value: '2000', category: category, priority: 1)
      expect(dup).not_to be_valid
      expect(dup.errors[:priority]).to include('should be unique per field/operator')
    end
  end
end
