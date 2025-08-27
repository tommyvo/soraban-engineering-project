class AutoCategorizeTransactionJob < ApplicationJob
  queue_as :default

  def perform(transaction_id)
    transaction = Transaction.find_by(id: transaction_id)
    return unless transaction

    # Always auto-categorize and override category if a rule matches
    matched = RuleService.categorize(transaction)
    if matched.present?
      transaction.update_columns(category: matched)
    end
  end
end
