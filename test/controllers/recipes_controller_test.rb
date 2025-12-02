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
    assert_select ".ingredient", 4
    assert_select ".step", 2
  end

  test "new" do
    get new_recipe_path
    assert_response :success
  end

  test "create" do
    assert_difference -> { @user.recipes.count } do
      post recipes_path, params: { recipe: {
        ingredients_text: "80 g oats\n300 ml milk",
        steps_text: "Simmer, stirring, for 5 minutes.",
        title: "Porridge", servings: 2, prep_minutes: 1, cook_minutes: 5
      } }
    end

    recipe = @user.recipes.order(:created_at).last
    assert_redirected_to recipe_path(recipe)
    assert_equal [ "oats", "milk" ], recipe.ingredients.map(&:name)
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
    assert_select "textarea[name='recipe[ingredients_text]']", /cups plain flour/
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

  test "someone else's recipe is not found" do
    get recipe_path(recipes(:soup))
    assert_response :not_found

    patch recipe_path(recipes(:soup)), params: { recipe: { title: "Mine now" } }
    assert_response :not_found
    assert_equal "Tomato Soup", recipes(:soup).reload.title

    assert_no_difference -> { Recipe.count } do
      delete recipe_path(recipes(:soup))
    end
  end

  test "tags from the form" do
    patch recipe_path(@recipe), params: { recipe: { tag_list: "breakfast, weekend" } }
    assert_equal [ "breakfast", "weekend" ], @recipe.reload.tags.map(&:name)
  end
end
