require "test_helper"

class DemoDataTest < ActiveSupport::TestCase
  test "creates the demo account with recipes, a plan and a pantry" do
    user = DemoData.load

    assert user.authenticate(DemoData::PASSWORD)
    assert_equal DemoData::RECIPES.size, user.recipes.count
    assert user.recipes.all? { |recipe| recipe.ingredients.any? && recipe.steps.any? }
    assert_equal DemoData::THIS_WEEK.size, user.meal_plan_entries.in_week(Week.current).count
    assert user.pantry_items.any?(&:staple?)
    assert_not GroceryList.new(user, Week.current).empty?
  end

  test "running it again changes nothing" do
    DemoData.load
    assert_no_difference -> { Recipe.count } do
      DemoData.load
    end
  end

  test "every demo ingredient line parses into something sensible" do
    DemoData::RECIPES.each do |recipe|
      recipe[:ingredients].lines.each do |line|
        parsed = IngredientParser.parse(line)
        assert parsed.name.present?, "#{line.inspect} has no name"
        assert parsed.name.length < 40, "#{line.inspect} parsed to #{parsed.name.inspect}"
      end
    end
  end
end
