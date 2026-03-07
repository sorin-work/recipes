require "test_helper"

class GroceryListsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @week = Week.current
    sign_in_as @user
  end

  test "empty week" do
    get grocery_list_path
    assert_response :success
    assert_select "h2", "Nothing to buy yet"
  end

  test "lists what the plan needs" do
    @user.meal_plan_entries.create!(recipe: recipes(:pasta), on: @week.start, meal: "dinner", servings: 4)

    get grocery_list_path(week: @week)
    assert_response :success
    assert_select ".grocery-item", /spaghetti.*400 g/m
  end

  test "grouped by aisle" do
    @user.meal_plan_entries.create!(recipe: recipes(:pasta), on: @week.start, meal: "dinner")

    get grocery_list_path
    assert_select ".grocery-section h2", "Produce"
  end
end
