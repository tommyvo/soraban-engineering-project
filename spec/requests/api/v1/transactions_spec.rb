require 'rails_helper'

describe "GET /api/v1/transactions/spending_summary", type: :request do
  it "returns the last 7 days of spending totals" do
    Transaction.delete_all
    # Create transactions for the last 7 days
    (0..6).each do |i|
      create(:transaction, date: Date.today - i, amount: 10 * (i+1))
    end
    # Add a transaction outside the range
    create(:transaction, date: Date.today - 10, amount: 999)

    get "/api/v1/transactions/spending_summary"
    expect(response).to have_http_status(:ok)
    json = JSON.parse(response.body)
    expect(json.length).to eq(7)
    # Should be ordered oldest to newest
    expect(json.first["date"]).to eq((Date.today - 6).strftime('%Y-%m-%d'))
    expect(json.last["date"]).to eq(Date.today.strftime('%Y-%m-%d'))
    # Check spending values
    expect(json.last["spending"]).to eq(10.0)
    expect(json.first["spending"]).to eq(70.0)
    # Should not include the out-of-range transaction
    expect(json.map { |d| d["spending"] }).not_to include(999.0)
  end
end
require 'rails_helper'

RSpec.describe "Api::V1::Transactions", type: :request do
  let(:valid_attributes) { attributes_for(:transaction) }

  describe "GET /api/v1/transactions" do
    it "returns a list of transactions ordered by date descending" do
      t1 = create(:transaction, valid_attributes.merge(date: Date.today - 1))
      t2 = create(:transaction, valid_attributes.merge(date: Date.today))

      get "/api/v1/transactions"
      expect(response).to have_http_status(:ok)

  json = JSON.parse(response.body)
  txs = json["transactions"]
  expect(txs).to be_an(Array)
  expect(txs.first["id"]).to eq(t2.id)
  expect(txs.second["id"]).to eq(t1.id)
    end
  end

  describe "GET /api/v1/transactions/:id" do
    it "returns a single transaction" do
      transaction = create(:transaction, valid_attributes)

      get "/api/v1/transactions/#{transaction.id}"
      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      expect(json["id"]).to eq(transaction.id)
      expect(json["description"]).to eq("Test Transaction")
    end
  end

  describe "POST /api/v1/transactions" do
    it "creates a new transaction with valid params" do
      expect {
        post "/api/v1/transactions", params: { transaction: valid_attributes }
      }.to change(Transaction, :count).by(1)

      expect(response).to have_http_status(:created)

      json = JSON.parse(response.body)
      expect(json["description"]).to eq("Test Transaction")
    end

    it "creates a transaction and flags anomalies with incomplete params" do
      perform_enqueued_jobs do
        expect {
          post "/api/v1/transactions", params: { transaction: { description: "" } }
        }.to change(Transaction, :count).by(1)

        expect(response).to have_http_status(:created)

        json = JSON.parse(response.body)
        expect(json["description"]).to eq("")

        tx = Transaction.find(json["id"])
        expect(tx.anomalies).not_to be_empty
        expect(tx.anomalies.first.anomaly_type).to eq("MissingData")
      end
    end
  end

  describe "POST /api/v1/transactions/:id/approve" do
    it "approves a transaction and sets approval fields" do
      tx = create(:transaction, description: nil, amount: rand(1000..9999), date: Date.today - rand(1..100))

      post "/api/v1/transactions/#{tx.id}/approve"
      expect(response).to have_http_status(:ok)

      tx = Transaction.find(tx.id)
      expect(tx.approved).to eq(true)
      expect(tx.approved_at).not_to be_nil
      expect(tx.reviewed_by).to eq("user")
    end
  end
end
