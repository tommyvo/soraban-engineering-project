module Api
  module V1
    class FlaggedTransactionsController < ApplicationController
      def index
        transactions = Transaction.joins(:anomalies)
          .where.not(approved: true)
          .includes(:anomalies)
          .distinct
          .order(date: :desc)
          .page(params[:page]).per(params[:per_page] || 25)
        render json: {
          transactions: transactions.as_json(
            include: { anomalies: { only: [ :id, :anomaly_type, :reason, :created_at ] } },
            only: [ :id, :description, :amount, :category, :date, :created_at ]
          ),
          total_pages: transactions.total_pages,
          current_page: transactions.current_page,
          total_count: transactions.total_count
        }
      end
    end
  end
end
