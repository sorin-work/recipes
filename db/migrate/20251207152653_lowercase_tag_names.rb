# Tags are compared case-insensitively now. Merge tags that only differed in case
# into one lowercase tag before the names are rewritten.
class LowercaseTagNames < ActiveRecord::Migration[8.1]
  def up
    execute <<~SQL
      WITH ranked AS (
        SELECT id, user_id, LOWER(TRIM(name)) AS lowered,
               FIRST_VALUE(id) OVER (PARTITION BY user_id, LOWER(TRIM(name)) ORDER BY id) AS keep_id
        FROM tags
      )
      UPDATE taggings SET tag_id = ranked.keep_id
      FROM ranked
      WHERE taggings.tag_id = ranked.id AND ranked.id <> ranked.keep_id
        AND NOT EXISTS (
          SELECT 1 FROM taggings existing
          WHERE existing.recipe_id = taggings.recipe_id AND existing.tag_id = ranked.keep_id
        );
    SQL
    execute <<~SQL
      DELETE FROM taggings USING tags
      WHERE taggings.tag_id = tags.id
        AND EXISTS (
          SELECT 1 FROM tags other
          WHERE other.user_id = tags.user_id AND LOWER(TRIM(other.name)) = LOWER(TRIM(tags.name)) AND other.id < tags.id
        );
    SQL
    execute <<~SQL
      DELETE FROM tags
      WHERE EXISTS (
        SELECT 1 FROM tags other
        WHERE other.user_id = tags.user_id AND LOWER(TRIM(other.name)) = LOWER(TRIM(tags.name)) AND other.id < tags.id
      );
    SQL
    execute "UPDATE tags SET name = LOWER(TRIM(name))"
  end

  def down
    # Original capitalisation is gone; nothing to undo.
  end
end
