require "test_helper"

class IngredientTest < ActiveSupport::TestCase
  test "to_line puts the parts back together" do
    assert_equal "1 1/2 cups plain flour", ingredients(:pancakes_flour).to_line
    assert_equal "1 egg, beaten", ingredients(:pancakes_egg).to_line
    assert_equal "salt", ingredients(:pancakes_salt).to_line
    assert_equal "2 cloves garlic, sliced", ingredients(:pasta_garlic).to_line
  end

  test "lines survive a round trip through the parser" do
    [ "200 g spaghetti", "1 1/2 cups plain flour", "2 cloves garlic, sliced", "salt" ].each do |line|
      parsed = IngredientParser.parse(line)
      ingredient = Ingredient.new(quantity: parsed.quantity, unit: parsed.unit, name: parsed.name, note: parsed.note)
      assert_equal line, ingredient.to_line
    end
  end

  test "amount scales" do
    assert_equal "3 cups", ingredients(:pancakes_flour).amount(2)
    assert_equal "100 g", ingredients(:pasta_spaghetti).amount(1/2r)
    assert_nil ingredients(:pancakes_salt).amount(2)
  end

  test "rejects unknown units and non-positive quantities" do
    ingredient = Ingredient.new(recipe: recipes(:pasta), name: "x", unit: "bucket", quantity: 0)
    assert_not ingredient.valid?
    assert ingredient.errors[:unit].any?
    assert ingredient.errors[:quantity].any?
  end
end
