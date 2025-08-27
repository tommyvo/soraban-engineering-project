class AutoCategorizeTransactionJob < ApplicationJob
  queue_as :default

  def perform(transaction_id)
    transaction = Transaction.find_by(id: transaction_id)
    return unless transaction

    # Only auto-categorize if category is blank (don't overwrite user-set category)
    if transaction.category.blank?
      matched = RuleService.categorize(transaction)
      if matched.present?
        transaction.update_columns(category: matched)
      end
    end
  end
end
