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

  context 'edge cases' do
    it 'logs error for missing required fields' do
      bad_csv = "description,amount,category,created_at\n,3.50,Food,2023-01-01T00:00:00Z"
      csv_import.csv.attach(
        io: StringIO.new(bad_csv),
        filename: 'bad.csv',
        content_type: 'text/csv'
      )
      expect {
        described_class.perform_now(csv_import.id)
      }.not_to change { Transaction.count }
      csv_import.reload
      expect(csv_import.result['errors'].first['error']).to match(/Missing fields/)
    end

    it 'logs error for malformed amount' do
      bad_csv = "description,amount,category,created_at\nCoffee,notanumber,Food,2023-01-01T00:00:00Z"
      csv_import.csv.attach(
        io: StringIO.new(bad_csv),
        filename: 'bad.csv',
        content_type: 'text/csv'
      )
      expect {
        described_class.perform_now(csv_import.id)
      }.not_to change { Transaction.count }
      csv_import.reload
      expect(csv_import.result['errors'].first['error']).to eq('Invalid amount')
    end

    it 'logs error for invalid metadata JSON' do
      bad_csv = "description,amount,category,created_at,metadata\nCoffee,3.50,Food,2023-01-01T00:00:00Z,{notjson}"
      csv_import.csv.attach(
        io: StringIO.new(bad_csv),
        filename: 'bad.csv',
        content_type: 'text/csv'
      )
      expect {
        described_class.perform_now(csv_import.id)
      }.not_to change { Transaction.count }
      csv_import.reload
      expect(csv_import.result['errors'].first['error']).to eq('Invalid metadata JSON')
    end

    it 'logs error for duplicate description, amount, and category' do
      Transaction.create!(description: 'Coffee', amount: 3.50, category: 'Food')
      dup_csv = "description,amount,category\nCoffee,3.50,Food"
      csv_import.csv.attach(
        io: StringIO.new(dup_csv),
        filename: 'dup.csv',
        content_type: 'text/csv'
      )
      expect {
        described_class.perform_now(csv_import.id)
      }.not_to change { Transaction.count }
      csv_import.reload
      expect(csv_import.result['errors'].first['error']).to match(/already exists/)
    end

    it 'sets status to failed and result with error if CSV parsing explodes' do
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
