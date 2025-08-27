require 'rails_helper'

RSpec.describe "Api::V1::Transactions", type: :request do
  let(:valid_attributes) { attributes_for(:transaction) }

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
