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
        row_hash = row.to_h
        # Check for required fields

        required = %w[description amount category date]
        missing = required.select { |f| row_hash[f].blank? }
        if missing.any?
          errors << {row: row_hash, error: "Missing fields: #{missing.join(', ')}"}
          next
        end

        # Parse date (MM/DD/YYYY)
        begin
          parsed_date = Date.strptime(row_hash['date'], '%m/%d/%Y')
        rescue => e
          errors << {row: row_hash, error: 'Invalid date format (expected MM/DD/YYYY)'}
          next
        end

        # Validate amount
        unless row_hash['amount'].to_s.match?(/\A-?\d+(\.\d+)?\z/)
          errors << {row: row_hash, error: 'Invalid amount'}
          next
        end



        begin
          Transaction.create!(
            description: row_hash['description'],
            amount: row_hash['amount'],
            category: row_hash['category'],
            date: parsed_date
          )
          imported += 1
        rescue => e
          errors << {row: row_hash, error: e.message}
        end
      end
      csv_import.update!(status: 'completed', result: {imported: imported, errors: errors})
    rescue => e
      csv_import.update!(status: 'failed', result: {error: e.message})
    end
  end
end
