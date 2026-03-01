require "test_helper"

class AisleTest < ActiveSupport::TestCase
  test "common ingredients" do
    assert_equal "produce", Aisle.for("Red onions")
    assert_equal "meat & fish", Aisle.for("chicken thighs")
    assert_equal "dairy & eggs", Aisle.for("large eggs")
    assert_equal "bakery", Aisle.for("tortillas")
    assert_equal "pantry", Aisle.for("plain flour")
    assert_equal "spices", Aisle.for("ground cumin")
    assert_equal "frozen", Aisle.for("frozen peas")
  end

  test "the last word decides" do
    assert_equal "pantry", Aisle.for("chicken stock")
    assert_equal "pantry", Aisle.for("tomato paste")
    assert_equal "pantry", Aisle.for("coconut milk")
  end

  test "pepper the spice and pepper the vegetable" do
    assert_equal "spices", Aisle.for("black pepper")
    assert_equal "produce", Aisle.for("red pepper")
    assert_equal "spices", Aisle.for("salt and pepper")
  end

  test "dried herbs and ground spices" do
    assert_equal "spices", Aisle.for("dried thyme")
    assert_equal "spices", Aisle.for("ground coriander")
    assert_equal "produce", Aisle.for("green beans")
    assert_equal "pantry", Aisle.for("baking powder")
  end

  test "anything else" do
    assert_equal "other", Aisle.for("kitchen string")
  end
end
