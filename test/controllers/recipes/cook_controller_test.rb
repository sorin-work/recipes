require "test_helper"

class Recipes::CookControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:one) }

  test "shows the steps one by one" do
    get recipe_cook_path(recipes(:pancakes))
    assert_response :success
    assert_select ".cook__step", 2
    assert_select ".cook__step.is-current", 1
  end

  test "scaled ingredients" do
    get recipe_cook_path(recipes(:pancakes), servings: 2)
    assert_select ".cook__ingredients", /3\/4 cup plain flour/
  end
end
