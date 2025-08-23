require 'rails_helper'

describe ImportTransactionsCsvJob, type: :job do
  let(:csv_import) { CsvImport.create!(status: 'pending') }
  let(:csv_content) do
    "description,amount,category,metadata\nCoffee,3.50,Food,\"{\"\"note\"\":\"\"morning\"\"}\"\nBook,12.99,Education,\"{\"\"author\"\":\"\"Doe\"\"}\""
  end

  before do
    csv_import.csv.attach(
      io: StringIO.new(csv_content),
      filename: 'transactions.csv',
      content_type: 'text/csv'
    )
  end

  it 'imports transactions from the attached CSV and updates status/result' do
    expect {
      described_class.perform_now(csv_import.id)
    }.to change { Transaction.count }.by(2)

    csv_import.reload
    expect(csv_import.status).to eq('completed')
    expect(csv_import.result).to include('imported' => 2)
  end

  context 'failed imports' do
    it 'sets status to failed and result with error' do
      expect(CSV).to receive(:parse).and_raise("boom something broke")
      expect {
        described_class.perform_now(csv_import.id)
      }.not_to change { Transaction.count }

      csv_import.reload
      expect(csv_import.status).to eq('failed')
      expect(csv_import.result['error']).to be_present
    end
  end
end
