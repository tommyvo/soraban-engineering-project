class CreateAnomalies < ActiveRecord::Migration[7.1]
  def change
    create_table :anomalies do |t|
      t.references :transaction, null: false, foreign_key: true
      t.string :anomaly_type, null: false
      t.string :reason
      t.timestamps
    end
  end
end
