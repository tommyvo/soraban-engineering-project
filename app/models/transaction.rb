class Transaction < ApplicationRecord
  validates :description, presence: true
  validates :amount, presence: true, numericality: true
  validates :category, presence: true
end
