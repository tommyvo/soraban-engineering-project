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

    it 'broadcasts after every batch is processed' do
      # Batch size is 500, so 1001 rows = 3 batches (500, 500, 1)
      batch_size = 500
      total_rows = batch_size * 2 + 1

      # Create enough rows to trigger the batching
      csv_rows = (1..total_rows).map { |i| "desc#{i},1.00,Cat,08/23/2025" }.join("\n")
      csv = "description,amount,category,date\n" + csv_rows

      csv_import.csv.attach(
        io: StringIO.new(csv),
        filename: 'big.csv',
        content_type: 'text/csv'
      )

      allow(ActionCable.server).to receive(:broadcast)

      described_class.perform_now(csv_import.id)

      # Should broadcast once per batch (3 times)
      expect(ActionCable.server).to have_received(:broadcast).with("transactions", hash_including(action: "bulk_refresh")).exactly(3).times
    end
  end
end
