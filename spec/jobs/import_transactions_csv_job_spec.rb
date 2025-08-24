require 'rails_helper'

describe ImportTransactionsCsvJob, type: :job do
  let(:csv_import) { create(:csv_import) }
  let(:csv_content) do
    "description,amount,category,date\nCoffee,3.50,Food,08/23/2025\nBook,12.99,Education,08/22/2025"
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
      bad_csv = "description,amount,category,date\n,3.50,Food,08/23/2025"
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
      bad_csv = "description,amount,category,date\nCoffee,notanumber,Food,08/23/2025"
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


    it 'allows duplicate description, amount, category, and date' do
      create(:transaction, description: 'Coffee', amount: 3.50, category: 'Food', date: Date.strptime('08/23/2025', '%m/%d/%Y'))
      dup_csv = "description,amount,category,date\nCoffee,3.50,Food,08/23/2025"
      csv_import.csv.attach(
        io: StringIO.new(dup_csv),
        filename: 'dup.csv',
        content_type: 'text/csv'
      )
      expect {
        described_class.perform_now(csv_import.id)
      }.to change { Transaction.count }.by(1)
      csv_import.reload
      expect(csv_import.result['errors']).to be_empty
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
