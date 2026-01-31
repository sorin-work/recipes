class CreateMealPlanEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :meal_plan_entries do |t|
      t.references :user, null: false, foreign_key: true, index: false
      t.references :recipe, null: false, foreign_key: true
      t.date :on, null: false
      t.string :meal, null: false
      t.integer :servings, null: false

      t.timestamps
    end
    add_index :meal_plan_entries, [ :user_id, :on ]
  end
end
