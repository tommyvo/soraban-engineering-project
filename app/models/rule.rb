class Rule < ApplicationRecord
  FIELDS = %w[description amount].freeze
  OPERATORS = %w[contains > < =].freeze

  validates :field, :operator, :value, :category, :priority, presence: true
  validates :priority, uniqueness: { scope: [:field, :operator], message: "should be unique per field/operator" }
  validates :field, inclusion: { in: FIELDS }
  validates :operator, inclusion: { in: OPERATORS }

  validate :operator_field_combination

  private

  def operator_field_combination
    if field == "description" && operator != "contains"
      errors.add(:operator, 'must be "contains" when field is "description"')
    end

    if field == "amount" && !%w[> < =].include?(operator)
      errors.add(:operator, 'must be one of >, <, = when field is "amount"')
    end
  end
end
