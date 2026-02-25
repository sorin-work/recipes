require "test_helper"

class IngredientNameTest < ActiveSupport::TestCase
  test "plural, size and preparation words don't matter" do
    assert_equal "onion", IngredientName.key("Onions")
    assert_equal "onion", IngredientName.key("large onion")
    assert_equal "egg", IngredientName.key("eggs (beaten)")
    assert_equal "tomato", IngredientName.key("ripe tomatoes")
    assert_equal "red onion", IngredientName.key("Red Onions")
  end

  test "punctuation is ignored" do
    assert_equal "parmesan", IngredientName.key("parmesan!")
    assert_equal "self-raising flour", IngredientName.key("Self-raising flour")
  end

  test "empty names" do
    assert_equal "", IngredientName.key("")
    assert_equal "", IngredientName.key("chopped")
  end
end
