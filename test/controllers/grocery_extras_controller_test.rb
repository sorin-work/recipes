require "test_helper"

class GroceryExtrasControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @week = Week.current
    sign_in_as @user
  end

  test "add, tick and remove an extra" do
    post grocery_extras_path(week: @week), params: { grocery_extra: { name: " Coffee  beans " } }
    assert_redirected_to grocery_list_path(week: @week)

    extra = @user.grocery_extras.sole
    assert_equal "Coffee beans", extra.name
    assert_equal @week.start, extra.week_start

    patch grocery_extra_path(extra), params: { grocery_extra: { checked: "1" } }
    assert extra.reload.checked

    delete grocery_extra_path(extra)
    assert_not GroceryExtra.exists?(extra.id)
  end

  test "blank extras are refused" do
    post grocery_extras_path(week: @week), params: { grocery_extra: { name: " " } }
    assert_equal 0, @user.grocery_extras.count
    assert_match(/can't be blank/, flash[:alert])
  end

  test "extras show on the list" do
    @user.grocery_extras.create!(week_start: @week.start, name: "kitchen roll")
    get grocery_list_path
    assert_select ".grocery-extras", /kitchen roll/
  end

  test "someone else's extra" do
    extra = users(:two).grocery_extras.create!(week_start: @week.start, name: "tea")
    delete grocery_extra_path(extra)
    assert_response :not_found
  end
end
