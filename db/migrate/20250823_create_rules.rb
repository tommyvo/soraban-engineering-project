class CreateRules < ActiveRecord::Migration[7.1]
  def change
    create_table :rules do |t|
      t.string :field, null: false
      t.string :operator, null: false
      t.string :value, null: false
      t.string :category, null: false
      t.integer :priority, null: false

      t.timestamps
    end
    add_index :rules, [ :field, :operator, :priority ], unique: true
  end
end
