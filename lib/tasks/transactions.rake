namespace :transactions do
  desc "Enqueue auto-categorization jobs for all transactions"
  task auto_categorize_all: :environment do
    batch_size = 100
    Transaction.find_in_batches(batch_size: batch_size) do |batch|
      batch.each do |tx|
        AutoCategorizeTransactionJob.perform_later(tx.id)
      end
      # Broadcast after each batch
      ActionCable.server.broadcast("transactions", { action: "bulk_refresh" })
    end
    puts "Enqueued auto-categorization jobs for all transactions."
  end

  desc "Enqueue anomaly checker jobs for all transactions"
  task check_anomalies_all: :environment do
    batch_size = 100
    Transaction.find_in_batches(batch_size: batch_size) do |batch|
      batch.each do |tx|
        AnomalyCheckerJob.perform_later(tx.id)
      end
      # Broadcast after each batch
      ActionCable.server.broadcast("transactions", { action: "bulk_refresh" })
    end
    puts "Enqueued anomaly checker jobs for all transactions."
  end
end
