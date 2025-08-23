require 'rails_helper'

describe 'CSV Imports API', type: :request do
  describe 'POST /api/v1/csv_imports' do
    let(:csv_file) do
      fixture_file_upload(Rails.root.join('spec/fixtures/files/transactions.csv'), 'text/csv')
    end

    it 'creates a CsvImport, attaches the file, and enqueues the job' do
      expect {
        post '/api/v1/csv_imports', params: { csv: csv_file }
      }.to change(CsvImport, :count).by(1)

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['id']).to be_present
      expect(json['status']).to eq('pending')
    end

    it 'returns error if no file is provided' do
      post '/api/v1/csv_imports'
      expect(response).to have_http_status(:bad_request)
      expect(JSON.parse(response.body)['error']).to be_present
    end
  end
end
