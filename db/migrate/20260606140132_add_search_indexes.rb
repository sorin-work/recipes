# Recipe search uses ILIKE '%word%' on titles and ingredient names, which a
# plain btree index can't help with. Trigram indexes can.
class AddSearchIndexes < ActiveRecord::Migration[8.1]
  def change
    enable_extension "pg_trgm"

    add_index :recipes, :title, using: :gin, opclass: :gin_trgm_ops, name: "index_recipes_on_title_trgm"
    add_index :ingredients, :name, using: :gin, opclass: :gin_trgm_ops, name: "index_ingredients_on_name_trgm"
  end
end
