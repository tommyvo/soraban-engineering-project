module Api
  module V1
    class CsvImportsController < ActionController::API
      # POST /api/v1/csv_imports
      def create
        unless params[:csv].present?
          return render json: { error: 'CSV file is required' }, status: :bad_request
        end

        csv_import = CsvImport.create!(status: 'pending')
        csv_import.csv.attach(params[:csv])
        ImportTransactionsCsvJob.perform_later(csv_import.id)
        render json: { id: csv_import.id, status: csv_import.status }, status: :created
      end
    end
  end
end
