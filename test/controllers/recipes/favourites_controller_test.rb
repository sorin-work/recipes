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

  test "answers turbo streams so the list page stays put" do
    post recipe_favourite_path(recipes(:pasta)), as: :turbo_stream
    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", response.media_type
    assert_select "turbo-stream[action=replace][target=?]", "favourite_recipe_#{recipes(:pasta).id}"
  end

  test "can't favourite someone else's recipe" do
    post recipe_favourite_path(recipes(:soup))
    assert_response :not_found
    assert_not recipes(:soup).reload.favourite?
  end
end
