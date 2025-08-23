class RuleService
  # Returns the category if a rule matches, or nil if none match
  def self.categorize(transaction)
    Rule.order(:priority, :id).each do |rule|
      case rule.field
      when "description"
        if rule.operator == "contains" && transaction.description.to_s.downcase.include?(rule.value.downcase)
          return rule.category
        end
      when "amount"
        amount = transaction.amount.to_f
        value = rule.value.to_f

        case rule.operator
        when ">"
          return rule.category if amount > value
        when "<"
          return rule.category if amount < value
        when "="
          return rule.category if amount == value
        end
      end
    end

    nil
  end
end
