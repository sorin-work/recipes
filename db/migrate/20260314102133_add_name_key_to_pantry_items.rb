# Pantry items are matched to grocery list lines by normalised name ("Eggs" and
# "egg" are the same thing), so store that key and make it unique per user.
class AddNameKeyToPantryItems < ActiveRecord::Migration[8.1]
  class PantryItem < ActiveRecord::Base
    self.table_name = "pantry_items"
  end

  def up
    add_column :pantry_items, :name_key, :string

    PantryItem.reset_column_information
    seen = Set.new
    PantryItem.order(:id).find_each do |item|
      key = IngredientName.key(item.name)
      if seen.add?([ item.user_id, key ])
        item.update_columns(name_key: key)
      else
        item.delete
      end
    end

    change_column_null :pantry_items, :name_key, false
    add_index :pantry_items, [ :user_id, :name_key ], unique: true
  end

  def down
    remove_index :pantry_items, [ :user_id, :name_key ]
    remove_column :pantry_items, :name_key
  end
end
