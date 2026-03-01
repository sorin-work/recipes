class CreateGroceryChecks < ActiveRecord::Migration[8.1]
  def change
    create_table :grocery_checks do |t|
      t.references :user, null: false, foreign_key: true, index: false
      t.date :week_start, null: false
      t.string :item_key, null: false

      t.timestamps
    end
    add_index :grocery_checks, [ :user_id, :week_start, :item_key ], unique: true
  end
end
