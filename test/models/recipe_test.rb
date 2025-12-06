require "test_helper"

class RecipeTest < ActiveSupport::TestCase
  setup { @user = users(:one) }

  test "needs a title and sensible servings and times" do
    recipe = @user.recipes.new(title: " ", servings: 0, prep_minutes: -5, cook_minutes: 3000)
    assert_not recipe.valid?
    assert recipe.errors[:title].any?
    assert recipe.errors[:servings].any?
    assert recipe.errors[:prep_minutes].any?
    assert recipe.errors[:cook_minutes].any?
  end

  test "squishes the title" do
    assert_equal "Fish Pie", Recipe.new(title: "  Fish   Pie ").title
  end

  test "total minutes" do
    assert_equal 30, recipes(:pancakes).total_minutes
    assert_equal 30, recipes(:soup).total_minutes
    assert_nil Recipe.new.total_minutes
  end

  test "ingredients come from one line each" do
    recipe = @user.recipes.create!(title: "Toast", servings: 1, ingredients_text: "2 slices bread\n\n1 tbsp butter\n")

    assert_equal [ "bread", "butter" ], recipe.ingredients.map(&:name)
    assert_equal [ 1, 2 ], recipe.ingredients.map(&:position)
    assert_equal "slice", recipe.ingredients.first.unit
    assert_equal "2 slices bread\n1 tbsp butter", recipe.reload.ingredients_text
  end

  test "editing the ingredient text replaces the ingredients" do
    recipe = recipes(:pasta)
    recipe.update!(ingredients_text: "300 g penne")

    assert_equal [ "penne" ], recipe.reload.ingredients.map(&:name)
  end

  test "leaving ingredients alone keeps them" do
    recipe = recipes(:pasta)
    recipe.update!(title: "Spaghetti aglio e olio")

    assert_equal 3, recipe.reload.ingredients.count
  end

  test "rejects absurdly long ingredient lists" do
    recipe = @user.recipes.new(title: "Too much", servings: 1, ingredients_text: "1 egg\n" * 101)
    assert_not recipe.valid?
    assert recipe.errors[:ingredients_text].any?
  end

  test "steps split on lines or blank lines" do
    recipe = @user.recipes.create!(title: "Tea", servings: 1, steps_text: "Boil water.\nPour.\nWait.")
    assert_equal [ "Boil water.", "Pour.", "Wait." ], recipe.steps.map(&:body)

    recipe.update!(steps_text: "Boil the water\nin a kettle.\n\nPour it over the tea.")
    assert_equal [ "Boil the water in a kettle.", "Pour it over the tea." ], recipe.reload.steps.map(&:body)
  end

  test "tags come from a comma separated list" do
    recipe = @user.recipes.create!(title: "Salad", servings: 2, tag_list: "quick, summer ,, quick")

    assert_equal [ "quick", "summer" ], recipe.tags.map(&:name).sort
    assert_equal tags(:quick), recipe.tags.find_by(name: "quick"), "reuses the existing tag"
  end

  test "search matches titles and descriptions" do
    assert_equal [ recipes(:pasta) ], @user.recipes.search("spaghetti").to_a
    assert_equal [ recipes(:pancakes) ], @user.recipes.search("weekend").to_a
    assert_empty @user.recipes.search("tomato")
  end

  test "tagged" do
    assert_equal [ recipes(:pancakes) ], @user.recipes.tagged("breakfast").to_a
  end
end
