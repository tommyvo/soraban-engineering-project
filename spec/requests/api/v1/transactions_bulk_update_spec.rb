require 'rails_helper'

describe 'Bulk Categorization API', type: :request do
  let!(:tx1) { Transaction.create!(description: 'A', amount: 1, category: 'Old', date: Date.today) }
  let!(:tx2) { Transaction.create!(description: 'B', amount: 2, category: 'Old', date: Date.today) }
  let!(:tx3) { Transaction.create!(description: 'C', amount: 3, category: 'Other', date: Date.today) }

  it 'updates category for selected transactions' do
    post '/api/v1/transactions/bulk_update', params: {
      ids: [tx1.id, tx2.id],
      category: 'NewCat'
    }
    expect(response).to have_http_status(:ok)
    expect(tx1.reload.category).to eq('NewCat')
    expect(tx2.reload.category).to eq('NewCat')
    expect(tx3.reload.category).to eq('Other')
  end

  it 'returns error if ids or category missing' do
    post '/api/v1/transactions/bulk_update', params: { ids: [tx1.id] }
    expect(response).to have_http_status(:bad_request)
    post '/api/v1/transactions/bulk_update', params: { category: 'X' }
    expect(response).to have_http_status(:bad_request)
  end

  it 'ignores invalid ids' do
    post '/api/v1/transactions/bulk_update', params: { ids: [0, tx1.id], category: 'Bulked' }
    expect(response).to have_http_status(:ok)
    expect(tx1.reload.category).to eq('Bulked')
  end
end
