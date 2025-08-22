class CreateCsvImports < ActiveRecord::Migration[8.0]
  def change
    create_table :csv_imports do |t|
      t.string :status
      t.jsonb :result

      t.timestamps
    end
  end
end
