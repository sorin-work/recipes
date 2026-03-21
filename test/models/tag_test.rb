require "test_helper"

class TagTest < ActiveSupport::TestCase
  test "names are unique per user" do
    assert_not users(:one).tags.new(name: "quick").valid?
    assert users(:two).tags.new(name: "quick").valid?
  end

  test "names are lowercased and squished" do
    assert_equal "weeknight dinner", Tag.new(name: "  Weeknight   Dinner ").name
  end

  test "names that differ only in case are the same tag" do
    assert_not users(:one).tags.new(name: "QUICK").valid?

    recipe = users(:one).recipes.create!(title: "Wrap", servings: 1, tag_list: "Quick, QUICK")
    assert_equal [ tags(:quick) ], recipe.tags.to_a
  end

  test "with_recipe_counts" do
    counts = users(:one).tags.with_recipe_counts.to_h { |tag| [ tag.name, tag.recipes_count ] }
    assert_equal({ "breakfast" => 1, "quick" => 1 }, counts)
  end
end
