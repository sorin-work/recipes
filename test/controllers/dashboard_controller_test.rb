require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  test "today's meals and the week" do
    user = users(:one)
    user.meal_plan_entries.create!(recipe: recipes(:pancakes), on: Date.current, meal: "breakfast")
    sign_in_as user

    get root_path
    assert_response :success
    assert_select "h1", "Hi Olive"
    assert_select ".dashboard__today", /Fluffy Pancakes/
    assert_select ".dashboard__week .stat", /1\s+of 7 days planned/
  end

  test "a new account sees how to start" do
    user = User.create!(name: "New Cook", email_address: "new@example.com", password: "long-password")
    sign_in_as user

    get root_path
    assert_select "h2", "Let's get your recipe box started"
  end
end
