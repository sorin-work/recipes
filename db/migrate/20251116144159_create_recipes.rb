class CreateRecipes < ActiveRecord::Migration[8.1]
  def change
    create_table :recipes do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.integer :servings, null: false, default: 4
      t.integer :prep_minutes
      t.integer :cook_minutes

      t.timestamps
    end
  end
end
