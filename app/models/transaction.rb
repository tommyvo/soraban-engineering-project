class Transaction < ApplicationRecord
  validates :description, uniqueness: { scope: [:amount, :category, :date], message: "with this amount, category, and date already exists" }
  validates :amount, presence: true, numericality: true

  before_validation :auto_categorize, on: :create

  private

  def auto_categorize
    matched = RuleService.categorize(self)
    self.category = matched if matched.present?
  end
end
