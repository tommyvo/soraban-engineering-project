require 'rails_helper'

describe CsvBatchImportJob, type: :job do
  let(:csv_import) { CsvImport.create!(csv: nil, status: 'pending') }

  it 'imports valid transactions' do
    rows = [
      { 'description' => 'Test 1', 'amount' => '10.00', 'category' => 'Food', 'date' => '01/01/2025' },
      { 'description' => 'Test 2', 'amount' => '20.00', 'category' => 'Travel', 'date' => '02/01/2025' }
    ]
    expect {
      CsvBatchImportJob.perform_now(csv_import.id, rows)
    }.to change { Transaction.count }.by(2)
  end

  it 'skips rows with missing required fields' do
    rows = [
      { 'description' => '', 'amount' => '10.00', 'category' => 'Food', 'date' => '01/01/2025' },
      { 'description' => 'Test 2', 'amount' => '20.00', 'category' => 'Travel', 'date' => '02/01/2025' }
    ]
    expect {
      CsvBatchImportJob.perform_now(csv_import.id, rows)
    }.to change { Transaction.count }.by(1)
  end

  it 'skips rows with invalid date format' do
    rows = [
      { 'description' => 'Test 1', 'amount' => '10.00', 'category' => 'Food', 'date' => 'bad-date' },
      { 'description' => 'Test 2', 'amount' => '20.00', 'category' => 'Travel', 'date' => '02/01/2025' }
    ]
    expect {
      CsvBatchImportJob.perform_now(csv_import.id, rows)
    }.to change { Transaction.count }.by(1)
  end

  it 'skips rows with invalid amount' do
    rows = [
      { 'description' => 'Test 1', 'amount' => 'notanumber', 'category' => 'Food', 'date' => '01/01/2025' },
      { 'description' => 'Test 2', 'amount' => '20.00', 'category' => 'Travel', 'date' => '02/01/2025' }
    ]
    expect {
      CsvBatchImportJob.perform_now(csv_import.id, rows)
    }.to change { Transaction.count }.by(1)
  end

  it 'handles empty rows array' do
    expect {
      CsvBatchImportJob.perform_now(csv_import.id, [])
    }.not_to change { Transaction.count }
  end
end
