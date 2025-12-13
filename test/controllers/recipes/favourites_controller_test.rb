require "test_helper"

class Recipes::FavouritesControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:one) }

  test "favourite and unfavourite" do
    recipe = recipes(:pasta)

    post recipe_favourite_path(recipe)
    assert recipe.reload.favourite?

    delete recipe_favourite_path(recipe)
    assert_not recipe.reload.favourite?
  end

  test "can't favourite someone else's recipe" do
    post recipe_favourite_path(recipes(:soup))
    assert_response :not_found
    assert_not recipes(:soup).reload.favourite?
  end
end
