require "test_helper"

class Recipes::DuplicatesControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:one) }

  test "copies a recipe and opens the copy for editing" do
    assert_difference -> { Recipe.count } do
      post recipe_duplicate_path(recipes(:pancakes))
    end

    copy = Recipe.order(:created_at).last
    assert_redirected_to edit_recipe_path(copy)
    assert_equal "Fluffy Pancakes (copy)", copy.title
    assert_equal 4, copy.ingredients.count
  end

  test "only my recipes" do
    post recipe_duplicate_path(recipes(:soup))
    assert_response :not_found
  end
end
