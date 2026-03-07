class CreateGroceryExtras < ActiveRecord::Migration[8.1]
  def change
    create_table :grocery_extras do |t|
      t.references :user, null: false, foreign_key: true, index: false
      t.date :week_start, null: false
      t.string :name, null: false
      t.boolean :checked, null: false, default: false

      t.timestamps
    end
    add_index :grocery_extras, [ :user_id, :week_start ]
  end
end
