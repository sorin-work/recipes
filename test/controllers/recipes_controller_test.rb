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

  test "search" do
    get recipes_path(q: "spaghetti")
    assert_select ".recipe-card__title", text: "Garlic Spaghetti"
    assert_select ".recipe-card__title", text: "Fluffy Pancakes", count: 0
  end

  test "search with no matches" do
    get recipes_path(q: "durian")
    assert_select "h2", "Nothing matches"
  end

  test "filter by tag" do
    get recipes_path(tag: "breakfast")
    assert_select ".recipe-card__title", count: 1, text: "Fluffy Pancakes"
  end

  test "tags without recipes are not offered as filters" do
    @user.tags.create!(name: "abandoned")
    get recipes_path
    assert_select "select[name=tag] option", text: "breakfast"
    assert_select "select[name=tag] option", text: "abandoned", count: 0
  end

  test "favourites only" do
    get recipes_path(favourites: "1")
    assert_select ".recipe-card__title", count: 1, text: "Fluffy Pancakes"
  end

  test "pages" do
    30.times { |i| @user.recipes.create!(title: "Recipe #{i}", servings: 2) }

    get recipes_path(q: "recipe")
    assert_select ".recipe-card", Recipe::PER_PAGE
    assert_select ".pagination__status", "Page 1 of 2"

    get recipes_path(q: "recipe", page: 2)
    assert_select ".recipe-card", 30 - Recipe::PER_PAGE
  end

  test "a page past the end shows the last page" do
    30.times { |i| @user.recipes.create!(title: "Recipe #{i}", servings: 2) }

    get recipes_path(page: 99)
    assert_select ".pagination__status", "Page 2 of 2"
    assert_select ".recipe-card", 32 - Recipe::PER_PAGE
  end

  test "page links keep the search" do
    30.times { |i| @user.recipes.create!(title: "Recipe #{i}", servings: 2) }

    get recipes_path(q: "recipe", sort: "title")
    assert_select "a[rel=next][href=?]", recipes_path(q: "recipe", sort: "title", page: 2)
  end

  test "show scaled to more servings" do
    get recipe_path(@recipe, servings: 8)
    assert_select ".ingredient__amount", text: "3 cups"
    assert_select "input[name=servings][value='8']"
  end

  test "ignores silly servings" do
    get recipe_path(@recipe, servings: 5000)
    assert_select "input[name=servings][value='4']"
  end

  test "upload a photo" do
    patch recipe_path(@recipe), params: { recipe: { photo: fixture_file_upload("photo.png", "image/png") } }
    assert_redirected_to recipe_path(@recipe)
    assert @recipe.reload.photo.attached?
  end

  test "remove the photo" do
    @recipe.photo.attach(io: file_fixture("photo.png").open, filename: "photo.png", content_type: "image/png")

    perform_enqueued_jobs do
      patch recipe_path(@recipe), params: { recipe: { title: @recipe.title, remove_photo: "1" } }
    end
    assert_not @recipe.reload.photo.attached?
  end

  test "tags from the form" do
    patch recipe_path(@recipe), params: { recipe: { tag_list: "breakfast, weekend" } }
    assert_equal [ "breakfast", "weekend" ], @recipe.reload.tags.map(&:name)
  end

  test "does not link to javascript urls" do
    @recipe.update_column(:source_url, "javascript:alert(1)")
    get recipe_path(@recipe)
    assert_select "a[href^='javascript']", count: 0
  end
end
