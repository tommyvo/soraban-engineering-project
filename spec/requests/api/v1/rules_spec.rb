require 'rails_helper'

RSpec.describe "Api::V1::Rules", type: :request do
  let(:valid_attributes) do
    {
      field: "description",
      operator: "contains",
      value: "coffee",
      category: "Food",
      priority: 1
    }
  end

  describe "GET /api/v1/rules" do
    let!(:rule) { create(:rule, valid_attributes) }

    it "returns all rules" do
      get "/api/v1/rules"

      expect(response).to have_http_status(:ok)
  json = JSON.parse(response.body)
  expect(json["rules"].size).to eq(1)
    end
  end

  describe "POST /api/v1/rules" do
    it "creates a rule with valid params" do
      expect {
        post "/api/v1/rules", params: { rule: valid_attributes }
      }.to change(Rule, :count).by(1)

      expect(response).to have_http_status(:created)

      json = JSON.parse(response.body)
      expect(json["category"]).to eq("Food")
    end

    it "returns errors with invalid params" do
      post "/api/v1/rules", params: { rule: valid_attributes.merge(field: "foo") }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)["errors"]).to be_present
    end
  end

  describe "PATCH /api/v1/rules/:id" do
    let!(:rule) { create(:rule, valid_attributes) }

    it "updates a rule" do
      patch "/api/v1/rules/#{rule.id}", params: { rule: { category: "Drinks" } }

      expect(response).to have_http_status(:ok)
      expect(rule.reload.category).to eq("Drinks")
    end
  end

  describe "DELETE /api/v1/rules/:id" do
    let!(:rule) { create(:rule, valid_attributes) }

    it "deletes a rule" do
      expect {
        delete "/api/v1/rules/#{rule.id}"
      }.to change(Rule, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end
  end
end
