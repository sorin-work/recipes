require "test_helper"

class GroceryChecksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @week = Week.current
    sign_in_as @user
  end

  test "tick and untick" do
    post grocery_check_path(week: @week, item_key: "spaghetti")
    assert_redirected_to grocery_list_path(week: @week)
    assert @user.grocery_checks.exists?(week_start: @week.start, item_key: "spaghetti")

    post grocery_check_path(week: @week, item_key: "spaghetti")
    assert_equal 1, @user.grocery_checks.count, "ticking twice is harmless"

    delete grocery_check_path(week: @week, item_key: "spaghetti")
    assert_not @user.grocery_checks.exists?
  end

  test "needs an item" do
    post grocery_check_path(week: @week)
    assert_response :bad_request
  end
end
