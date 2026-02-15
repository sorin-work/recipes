require "test_helper"

class PlansControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @week = Week.current
    sign_in_as @user
  end

  test "shows the current week" do
    @user.meal_plan_entries.create!(recipe: recipes(:pasta), on: @week.start, meal: "dinner")

    get plan_path
    assert_response :success
    assert_select ".planner__day", 7
    assert_select "##{"cell-#{@week.start.iso8601}-dinner"} .planner__entry-title", "Garlic Spaghetti"
  end

  test "another week" do
    get plan_path(week: @week.next.to_param)
    assert_response :success
    assert_select ".week-nav__label", @week.next.label
  end

  test "a week param that isn't a date shows this week" do
    get plan_path(week: "garbage")
    assert_response :success
    assert_select ".week-nav__label", @week.label
  end

  test "lists recipes to drag" do
    get plan_path
    assert_select ".planner__recipe[draggable=true]", 2
  end

  test "copy last week" do
    @user.meal_plan_entries.create!(recipe: recipes(:pasta), on: @week.previous.start + 2, meal: "dinner", servings: 3)

    assert_difference -> { @user.meal_plan_entries.in_week(@week).count } do
      post copy_previous_week_plan_path(week: @week)
    end
    assert_redirected_to plan_path(week: @week)

    copied = @user.meal_plan_entries.in_week(@week).sole
    assert_equal @week.start + 2, copied.on
    assert_equal 3, copied.servings
  end

  test "copying twice doesn't double up" do
    @user.meal_plan_entries.create!(recipe: recipes(:pasta), on: @week.previous.start, meal: "dinner")

    post copy_previous_week_plan_path(week: @week)
    post copy_previous_week_plan_path(week: @week)

    assert_equal 1, @user.meal_plan_entries.in_week(@week).count
  end

  test "clear a week" do
    @user.meal_plan_entries.create!(recipe: recipes(:pasta), on: @week.start, meal: "dinner")
    @user.meal_plan_entries.create!(recipe: recipes(:pasta), on: @week.next.start, meal: "dinner")

    delete clear_plan_path(week: @week)

    assert_redirected_to plan_path(week: @week)
    assert_equal 0, @user.meal_plan_entries.in_week(@week).count
    assert_equal 1, @user.meal_plan_entries.count
  end
end
