require 'rails_helper'

describe "GET /api/v1/flagged_transactions", type: :request do
  it "returns only transactions with anomalies and includes anomaly details" do
    tx_with_anomaly = nil
    tx_without_anomaly = nil
    perform_enqueued_jobs do
      tx_with_anomaly = Transaction.create!(description: nil, amount: rand(1000..9999), category: 'Test', date: Date.today - rand(1..100))
      tx_without_anomaly = Transaction.create!(description: 'Normal', amount: rand(10000..19999), category: 'Food', date: Date.today - rand(101..200))
      get "/api/v1/flagged_transactions"
    end
    json = JSON.parse(response.body)
    expect(json).to be_an(Array)

    ids = json.map { |t| t["id"] }
    expect(ids).to include(tx_with_anomaly.id)
    expect(ids).not_to include(tx_without_anomaly.id)

    flagged = json.find { |t| t["id"] == tx_with_anomaly.id }
    expect(flagged["anomalies"]).not_to be_empty
    expect(flagged["anomalies"][0]["anomaly_type"]).to eq("MissingData")
  end
end
