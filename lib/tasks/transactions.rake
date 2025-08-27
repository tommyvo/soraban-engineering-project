namespace :transactions do
  desc "Enqueue auto-categorization jobs for all transactions"
  task auto_categorize_all: :environment do
    Transaction.find_each(batch_size: 100) do |tx|
      AutoCategorizeTransactionJob.perform_later(tx.id)
    end
    puts "Enqueued auto-categorization jobs for all transactions."
  end

  desc "Enqueue anomaly checker jobs for all transactions"
  task check_anomalies_all: :environment do
    Transaction.find_each(batch_size: 100) do |tx|
      AnomalyCheckerJob.perform_later(tx.id)
    end
    puts "Enqueued anomaly checker jobs for all transactions."
  end
end
