require 'csv'

class ImportTransactionsCsvJob < ApplicationJob
  queue_as :default

  def perform(csv_import_id)
    csv_import = CsvImport.find(csv_import_id)
    csv_import.update!(status: 'processing')
    imported = 0
    errors = []

    begin
      csv_file = csv_import.csv.download

      CSV.parse(csv_file, headers: true) do |row|
        begin
          Transaction.create!(
            description: row['description'],
            amount: row['amount'],
            category: row['category'],
            metadata: row['metadata'] ? JSON.parse(row['metadata']) : {}
          )
          imported += 1
        rescue => e
          errors << { row: row.to_h, error: e.message }
        end
      end
      csv_import.update!(status: 'completed', result: { imported: imported, errors: errors })
    rescue => e
      csv_import.update!(status: 'failed', result: { error: e.message })
    end
  end
end
