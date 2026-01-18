require "test_helper"

class Recipes::ImportsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:one) }

  test "new" do
    get new_recipe_import_path
    assert_response :success
    assert_select "textarea[name='recipe_import[text]']"
  end

  test "create fills in the recipe form without saving" do
    assert_no_difference -> { Recipe.count } do
      post recipe_import_path, params: { recipe_import: { text: "Toast\nIngredients\n2 slices bread\nMethod\nToast the bread." } }
    end

    assert_response :unprocessable_entity
    assert_select "input[name='recipe[title]'][value=?]", "Toast"
    assert_select "textarea[name='recipe[ingredients_text]']", /2 slices bread/
    assert_select "form[action=?]", recipes_path
  end

  test "create with text that isn't a recipe" do
    post recipe_import_path, params: { recipe_import: { text: "hello" } }
    assert_response :unprocessable_entity
    assert_select ".form-errors", /ingredients or steps/
  end

  test "create without the text param" do
    post recipe_import_path, params: {}
    assert_response :bad_request
  end
end
