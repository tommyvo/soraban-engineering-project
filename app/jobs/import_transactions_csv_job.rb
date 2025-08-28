require "csv"

class ImportTransactionsCsvJob < ApplicationJob
  queue_as :default

  def perform(csv_import_id)
    csv_import = CsvImport.find(csv_import_id)
    csv_import.update!(status: "processing")
    imported = 0
    all_errors = []

    begin
      csv_file = csv_import.csv.download
      batch_size = 2000
      rows = []
      total_rows = 0

      Transaction.suppress_broadcasts do
        CSV.parse(csv_file, headers: true) do |row|
          rows << row.to_h
          if rows.size >= batch_size
            batch_errors = CsvBatchImportJob.perform_now(csv_import_id, rows)
            all_errors.concat(batch_errors) if batch_errors
            total_rows += rows.size
            rows = []
          end
        end

        # process any remaining rows
        unless rows.empty?
          batch_errors = CsvBatchImportJob.perform_now(csv_import_id, rows)
          all_errors.concat(batch_errors) if batch_errors
          total_rows += rows.size
        end
      end

      # After batch import, broadcast a single bulk_refresh event
      ActionCable.server.broadcast("transactions", { action: "bulk_refresh" })
      csv_import.update!(status: "completed", result: { imported: total_rows, errors: all_errors })
    rescue => e
      csv_import.update!(status: "failed", result: { error: e.message, errors: all_errors })
    end
  end
end
