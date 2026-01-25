require "test_helper"

class RecipeImportTest < ActiveSupport::TestCase
  def import(text)
    RecipeImport.new(text: text)
  end

  TOMATO_PASTA = <<~TEXT
    Weeknight Tomato Pasta

    A quick sauce from the cupboard.

    Ingredients
    - 400 g spaghetti
    - 2 tbsp olive oil
    - 3 cloves garlic, sliced

    Method
    1. Cook the pasta in salted water.
    2. Fry the garlic in the oil.
    3. Toss together and serve.
  TEXT

  test "reads the title, description, ingredients and steps" do
    attributes = import(TOMATO_PASTA).recipe_attributes

    assert_equal "Weeknight Tomato Pasta", attributes[:title]
    assert_equal "A quick sauce from the cupboard.", attributes[:description]
    assert_equal "400 g spaghetti\n2 tbsp olive oil\n3 cloves garlic, sliced", attributes[:ingredients_text]
    assert_equal "Cook the pasta in salted water.\n\nFry the garlic in the oil.\n\nToss together and serve.",
      attributes[:steps_text]
  end

  test "the result saves as a recipe" do
    recipe = users(:one).recipes.create!(servings: 4, **import(TOMATO_PASTA).recipe_attributes)
    assert_equal 3, recipe.ingredients.count
    assert_equal 3, recipe.steps.count
  end

  test "heading variations" do
    attributes = import("Toast\nYou will need:\n1 slice bread\nDirections:\nToast it.").recipe_attributes
    assert_equal "1 slice bread", attributes[:ingredients_text]
    assert_equal "Toast it.", attributes[:steps_text]
  end

  test "needs some text" do
    assert_not import("  ").valid?
  end

  test "needs ingredients or steps" do
    result = import("Just a title")
    assert_not result.valid?
    assert_includes result.errors[:text], "doesn't have any ingredients or steps we could find"
  end

  test "picks up servings and times" do
    attributes = import(<<~TEXT).recipe_attributes
      Banana Bread
      Serves: 10
      Prep time: 15 mins
      Cook time: 1 hr
      Total time: 1 hr 15 mins

      Ingredients
      3 bananas

      Method
      Mash and bake.
    TEXT

    assert_equal 10, attributes[:servings]
    assert_equal 15, attributes[:prep_minutes]
    assert_equal 60, attributes[:cook_minutes]
    assert_nil attributes[:description]
  end

  test "steps that start like a time stay steps" do
    attributes = import("Cake\nIngredients\n1 egg\nMethod\nBake for 30 minutes.\nCooking time depends on your oven.").recipe_attributes
    assert_equal "Bake for 30 minutes.\n\nCooking time depends on your oven.", attributes[:steps_text]
    assert_nil attributes[:cook_minutes]
  end

  test "yield and makes count as servings" do
    assert_equal 12, import("Muffins\nMakes 12 muffins\nIngredients\n1 egg").recipe_attributes[:servings]
    assert_equal 4, import("Stew\nYield: 4 servings\nIngredients\n1 egg").recipe_attributes[:servings]
  end

  test "strips step numbers in their usual forms" do
    attributes = import("Tea\nSteps\n1) Boil water.\nStep 2: Pour.\nStep 3\nWait 3 minutes.\n4 - Drink.").recipe_attributes
    assert_equal "Boil water.\n\nPour.\n\nWait 3 minutes.\n\nDrink.", attributes[:steps_text]
  end

  test "copes with windows line endings and non-breaking spaces" do
    attributes = import("Tea\r\nIngredients \r\n1 tea bag\r\nMethod\r\nBrew.\r\n").recipe_attributes
    assert_equal "Tea", attributes[:title]
    assert_equal "1 tea bag", attributes[:ingredients_text]
    assert_equal "Brew.", attributes[:steps_text]
  end

  test "keeps a source link" do
    attributes = import("Tea\nhttps://example.com/tea\nIngredients\n1 tea bag").recipe_attributes
    assert_equal "https://example.com/tea", attributes[:source_url]
    assert_nil attributes[:description]
  end

  test "guesses the sections when there are no headings" do
    attributes = import(<<~TEXT).recipe_attributes
      Scrambled Eggs
      Creamy and soft.
      3 eggs
      1 tbsp butter
      Whisk the eggs.
      Cook slowly in the butter, stirring.
    TEXT

    assert_equal "Creamy and soft.", attributes[:description]
    assert_equal "3 eggs\n1 tbsp butter", attributes[:ingredients_text]
    assert_equal "Whisk the eggs.\n\nCook slowly in the butter, stirring.", attributes[:steps_text]
  end
end
