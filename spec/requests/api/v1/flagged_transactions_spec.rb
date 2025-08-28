require 'rails_helper'

describe "GET /api/v1/flagged_transactions", type: :request do
  it "returns only transactions with anomalies, includes anomaly details, and orders by date descending" do
    tx_with_anomaly = nil
    tx_with_anomaly2 = nil
    tx_without_anomaly = nil

    perform_enqueued_jobs do
      tx_with_anomaly = Transaction.create!(description: nil, amount: rand(1000..9999), category: 'Test', date: Date.today - 1)
      tx_with_anomaly2 = Transaction.create!(description: nil, amount: rand(1000..9999), category: 'Test', date: Date.today)
      tx_without_anomaly = Transaction.create!(description: 'Normal', amount: rand(10000..19999), category: 'Food', date: Date.today - 2)

      get "/api/v1/flagged_transactions"
    end

  json = JSON.parse(response.body)
  txs = json["transactions"]
  expect(txs).to be_an(Array)

  ids = txs.map { |t| t["id"] }
  expect(ids).to include(tx_with_anomaly.id)
  expect(ids).to include(tx_with_anomaly2.id)
  expect(ids).not_to include(tx_without_anomaly.id)

  # Check ordering by date descending
  expect(txs.first["id"]).to eq(tx_with_anomaly2.id)
  expect(txs.second["id"]).to eq(tx_with_anomaly.id)

  flagged = txs.find { |t| t["id"] == tx_with_anomaly.id }
  expect(flagged["anomalies"]).not_to be_empty
  expect(flagged["anomalies"][0]["anomaly_type"]).to eq("MissingData")
  end
end
