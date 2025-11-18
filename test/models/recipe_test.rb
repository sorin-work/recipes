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
end
