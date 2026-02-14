require "test_helper"

class MealPlanEntriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @monday = Week.current.start
    sign_in_as @user
  end

  test "add from the recipe page goes to the planner" do
    assert_difference -> { @user.meal_plan_entries.count } do
      post meal_plan_entries_path, params: { meal_plan_entry: { recipe_id: recipes(:pasta).id, on: @monday, meal: "dinner" } }
    end
    assert_redirected_to plan_path(week: Week.current)
  end

  test "can't plan someone else's recipe" do
    assert_no_difference -> { MealPlanEntry.count } do
      post meal_plan_entries_path, params: { meal_plan_entry: { recipe_id: recipes(:soup).id, on: @monday, meal: "dinner" } }
    end
    assert_response :not_found
  end

  test "invalid meal" do
    assert_no_difference -> { MealPlanEntry.count } do
      post meal_plan_entries_path, params: { meal_plan_entry: { recipe_id: recipes(:pasta).id, on: @monday, meal: "elevenses" } }
    end
    assert_response :redirect
    assert_match(/Meal is not included/, flash[:alert])
  end

  test "add from the planner answers with the changed cell" do
    post meal_plan_entries_path(format: :turbo_stream), params: {
      from_planner: 1, meal_plan_entry: { recipe_id: recipes(:pasta).id, on: @monday, meal: "lunch" }
    }

    assert_response :success
    assert_select "turbo-stream[action=replace][target=?]", "cell-#{@monday.iso8601}-lunch"
  end

  test "json body from drag and drop" do
    post meal_plan_entries_path, as: :json, headers: { "Accept" => "text/vnd.turbo-stream.html" }, params: {
      from_planner: 1, meal_plan_entry: { recipe_id: recipes(:pancakes).id, on: @monday, meal: "breakfast" }
    }

    assert_response :success
    assert_equal "breakfast", @user.meal_plan_entries.last.meal
  end

  test "move to another day replaces both cells" do
    entry = @user.meal_plan_entries.create!(recipe: recipes(:pasta), on: @monday, meal: "dinner")

    patch meal_plan_entry_path(entry, format: :turbo_stream), params: {
      from_planner: 1, meal_plan_entry: { on: @monday + 1, meal: "dinner" }
    }

    assert_equal @monday + 1, entry.reload.on
    assert_select "turbo-stream[action=replace]", 2
  end

  test "change servings" do
    entry = @user.meal_plan_entries.create!(recipe: recipes(:pasta), on: @monday, meal: "dinner")

    patch meal_plan_entry_path(entry), params: { meal_plan_entry: { servings: 6 } }
    assert_equal 6, entry.reload.servings
  end

  test "remove" do
    entry = @user.meal_plan_entries.create!(recipe: recipes(:pasta), on: @monday, meal: "dinner")

    assert_difference -> { MealPlanEntry.count }, -1 do
      delete meal_plan_entry_path(entry, from_planner: 1, format: :turbo_stream)
    end
    assert_response :success
  end

  test "can't remove someone else's meal" do
    entry = users(:two).meal_plan_entries.create!(recipe: recipes(:soup), on: @monday, meal: "dinner")

    delete meal_plan_entry_path(entry)
    assert_response :not_found
    assert MealPlanEntry.exists?(entry.id)
  end
end
