module Api
  module V1
    class TransactionsController < ActionController::API
      before_action :set_transaction, only: [ :show, :update, :destroy, :approve ]

      # PATCH /api/v1/transactions/:id
      def update
        if @transaction.update(transaction_params)
          render json: @transaction
        else
          render json: { errors: @transaction.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/transactions/:id
      def destroy
        @transaction.destroy
        head :no_content
      end

      # POST /api/v1/transactions/:id/approve
      def approve
        @transaction.update!(approved: true, approved_at: Time.current, reviewed_by: "user")
        render json: @transaction
      end

      # GET /api/v1/transactions
      def index
        transactions = Transaction.order(date: :desc)
        render json: transactions
      end

      # GET /api/v1/transactions/:id
      def show
        render json: @transaction
      end

      # POST /api/v1/transactions
      def create
        transaction = Transaction.new(transaction_params)
        if transaction.save
          render json: transaction, status: :created
        else
          render json: { errors: transaction.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # POST /api/v1/transactions/bulk_update
      def bulk_update
        ids = params[:ids]
        category = params[:category]
        if ids.blank? || category.blank?
          return render json: { error: "ids and category are required" }, status: :bad_request
        end
        updated = Transaction.where(id: ids).update_all(category: category, updated_at: Time.current)
        render json: { updated: updated }, status: :ok
      end

      private

      def set_transaction
        @transaction = Transaction.find(params[:id])
      end

      def transaction_params
        params.require(:transaction).permit(:description, :amount, :category, :date)
      end
    end
  end
end
