class CreateIngredients < ActiveRecord::Migration[8.1]
  def change
    create_table :ingredients do |t|
      t.references :recipe, null: false, foreign_key: true
      t.integer :position, null: false, default: 0
      t.decimal :quantity, precision: 10, scale: 3
      t.string :unit
      t.string :name, null: false
      t.string :note

      t.timestamps
    end
  end
end
