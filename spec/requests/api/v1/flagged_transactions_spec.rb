require 'rails_helper'

describe "GET /api/v1/flagged_transactions", type: :request do
  let!(:tx_with_anomaly) do
    Transaction.create!(description: nil, amount: 10, category: 'Test', date: Date.today)
  end
  let!(:tx_without_anomaly) do
    Transaction.create!(description: 'Normal', amount: 5, category: 'Food', date: Date.today)
  end

  it "returns only transactions with anomalies and includes anomaly details" do
    get "/api/v1/flagged_transactions"
    expect(response).to have_http_status(:ok)

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
