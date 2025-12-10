class AddFavouriteToRecipes < ActiveRecord::Migration[8.1]
  def change
    add_column :recipes, :favourite, :boolean, null: false, default: false
    add_index :recipes, [ :user_id, :favourite ]
  end
end
