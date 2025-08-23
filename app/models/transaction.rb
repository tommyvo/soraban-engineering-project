class Transaction < ApplicationRecord
  validates :description, presence: true, uniqueness: { scope: [:amount, :category], message: "with this amount and category already exists" }
  validates :amount, presence: true, numericality: true
  validates :category, presence: true
end
