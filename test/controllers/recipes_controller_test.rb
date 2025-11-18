require "test_helper"

class RecipesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @recipe = recipes(:pancakes)
    sign_in_as @user
  end

  test "requires sign in" do
    sign_out
    get recipes_path
    assert_redirected_to new_session_path
  end

  test "index lists only my recipes" do
    get recipes_path
    assert_response :success
    assert_includes response.body, "Fluffy Pancakes"
    assert_not_includes response.body, "Tomato Soup"
  end

  test "show" do
    get recipe_path(@recipe)
    assert_response :success
    assert_select "h1", "Fluffy Pancakes"
  end

  test "new" do
    get new_recipe_path
    assert_response :success
  end

  test "create" do
    assert_difference -> { @user.recipes.count } do
      post recipes_path, params: { recipe: {
        title: "Porridge", servings: 2, prep_minutes: 1, cook_minutes: 5
      } }
    end

    recipe = @user.recipes.order(:created_at).last
    assert_redirected_to recipe_path(recipe)
  end

  test "create with errors re-renders the form" do
    assert_no_difference -> { Recipe.count } do
      post recipes_path, params: { recipe: { title: "", servings: 2 } }
    end
    assert_response :unprocessable_entity
    assert_select ".form-errors"
  end

  test "edit" do
    get edit_recipe_path(@recipe)
    assert_response :success
  end

  test "update" do
    patch recipe_path(@recipe), params: { recipe: { title: "Buttermilk Pancakes" } }
    assert_redirected_to recipe_path(@recipe)
    assert_equal "Buttermilk Pancakes", @recipe.reload.title
  end

  test "destroy" do
    assert_difference -> { Recipe.count }, -1 do
      delete recipe_path(@recipe)
    end
    assert_redirected_to recipes_path
  end
end
