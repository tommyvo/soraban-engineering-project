module Api
  module V1
    class FlaggedTransactionsController < ApplicationController
      def index
        transactions = Transaction.joins(:anomalies)
          .where.not(approved: true)
          .includes(:anomalies)
          .distinct
          .order(created_at: :desc)
        render json: transactions.as_json(
          include: { anomalies: { only: [:id, :anomaly_type, :reason, :created_at] } },
          only: [:id, :description, :amount, :category, :date, :created_at]
        )
      end
    end
  end
end
