require 'rails_helper'

RSpec.describe "Api::V1::Transactions", type: :request do
  let(:valid_attributes) { attributes_for(:transaction, metadata: {source: "manual"}) }

  describe "GET /api/v1/transactions" do
    it "returns a list of transactions" do
      create(:transaction, valid_attributes)
      get "/api/v1/transactions"
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to be_an(Array)
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
        post "/api/v1/transactions", params: {transaction: valid_attributes}
      }.to change(Transaction, :count).by(1)
      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json["description"]).to eq("Test Transaction")
    end

    it "creates a transaction and flags anomalies with incomplete params" do
      expect {
        post "/api/v1/transactions", params: {transaction: {description: ""}}
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
