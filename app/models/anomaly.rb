class Anomaly < ApplicationRecord
  belongs_to :transaction
  validates :anomaly_type, presence: true
  validates :reason, presence: true
end
