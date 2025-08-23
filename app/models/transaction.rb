class Transaction < ApplicationRecord
  validates :description, presence: true, uniqueness: { scope: [:amount, :category, :date], message: "with this amount, category, and date already exists" }
  validates :amount, presence: true, numericality: true
  validates :category, presence: true
  validates :date, presence: true
end
