require "test_helper"

class MealPlanEntryTest < ActiveSupport::TestCase
  test "defaults servings to the recipe's" do
    entry = users(:one).meal_plan_entries.create!(recipe: recipes(:pancakes), on: Date.current, meal: "breakfast")
    assert_equal 4, entry.servings
  end

  test "only accepts known meals" do
    entry = users(:one).meal_plan_entries.new(recipe: recipes(:pancakes), on: Date.current, meal: "brunch")
    assert_not entry.valid?
    assert entry.errors[:meal].any?
  end

  test "recipe must belong to the same user" do
    entry = users(:one).meal_plan_entries.new(recipe: recipes(:soup), on: Date.current, meal: "dinner")
    assert_not entry.valid?
    assert_includes entry.errors[:recipe], "is not one of your recipes"
  end

  test "scale is planned servings over recipe servings" do
    entry = MealPlanEntry.new(recipe: recipes(:pasta), servings: 5)
    assert_equal 5/2r, entry.scale
  end

  test "ordered by day then meal" do
    user = users(:one)
    monday = Week.current.start
    dinner = user.meal_plan_entries.create!(recipe: recipes(:pasta), on: monday, meal: "dinner")
    breakfast = user.meal_plan_entries.create!(recipe: recipes(:pancakes), on: monday, meal: "breakfast")
    tuesday = user.meal_plan_entries.create!(recipe: recipes(:pasta), on: monday + 1, meal: "breakfast")

    assert_equal [ breakfast, dinner, tuesday ], user.meal_plan_entries.ordered.to_a
  end
end
