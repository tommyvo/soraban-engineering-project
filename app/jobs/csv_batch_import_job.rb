# app/jobs/csv_batch_import_job.rb
class CsvBatchImportJob < ApplicationJob
  queue_as :default

  def perform(csv_import_id, rows)
    imported = 0
    errors = []

    rows.each do |row_hash|
      # Check for required fields
      required = %w[description amount category date]
      missing = required.select { |f| row_hash[f].blank? }

      if missing.any?
        errors << { row: row_hash, error: "Missing fields: #{missing.join(', ')}" }
        next
      end

      # Parse date (MM/DD/YYYY)
      begin
        parsed_date = Date.strptime(row_hash["date"], "%m/%d/%Y")
      rescue => e
        errors << { row: row_hash, error: "Invalid date format (expected MM/DD/YYYY)" }
        next
      end

      # Validate amount
      unless row_hash["amount"].to_s.match?(/\A-?\d+(\.\d+)?\z/)
        errors << { row: row_hash, error: "Invalid amount" }
        next
      end

      begin
        Transaction.create!(
          description: row_hash["description"],
          amount: row_hash["amount"],
          category: row_hash["category"],
          date: parsed_date
        )
        imported += 1
      rescue => e
        errors << { row: row_hash, error: e.message }
      end
    end
    # Return errors for aggregation
    errors
  end
end
