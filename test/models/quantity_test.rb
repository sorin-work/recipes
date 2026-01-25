require "test_helper"

class QuantityTest < ActiveSupport::TestCase
  test "parses whole numbers, decimals and fractions" do
    assert_equal 2, Quantity.parse("2")
    assert_equal 1.5r, Quantity.parse("1.5")
    assert_equal 1.5r, Quantity.parse("1,5")
    assert_equal 3/4r, Quantity.parse("3/4")
    assert_nil Quantity.parse("1/0")
    assert_nil Quantity.parse("a few")
  end

  test "scan splits the quantity from the rest of the line" do
    assert_equal [ 200, "g flour" ], Quantity.scan("200g flour")
    assert_equal [ 2, "eggs" ], Quantity.scan("2 eggs")
    assert_equal [ nil, "salt to taste" ], Quantity.scan("salt to taste")
  end

  test "parses unicode fractions" do
    assert_equal 1/2r, Quantity.parse("½")
    assert_equal 5/4r, Quantity.parse("1¼")
    assert_equal [ 3/2r, "cups milk" ], Quantity.scan("1 ½ cups milk")
    assert_equal [ 3/4r, "tsp salt" ], Quantity.scan("¾ tsp salt")
  end

  test "reads mixed numbers as one quantity" do
    assert_equal 3/2r, Quantity.parse("1 1/2")
    assert_equal [ 9/4r, "cups flour" ], Quantity.scan("2 1/4 cups flour")
  end

  test "ranges use the larger number" do
    assert_equal [ 3, "cloves garlic" ], Quantity.scan("2-3 cloves garlic")
    assert_equal [ 2, "onions" ], Quantity.scan("1 to 2 onions")
    assert_equal [ 4, "tomatoes" ], Quantity.scan("3 – 4 tomatoes")
  end

  test "formats cups and spoons as fractions" do
    assert_equal "1 1/2", Quantity.format(1.5, Unit["cup"])
    assert_equal "1/3", Quantity.format(1/3r, Unit["cup"])
    assert_equal "2/3", Quantity.format(0.667, Unit["cup"])
    assert_equal "3", Quantity.format(3, Unit["tbsp"])
    assert_equal "1/2", Quantity.format(0.5, nil)
  end

  test "formats metric amounts as decimals" do
    assert_equal "250", Quantity.format(250, Unit["g"])
    assert_equal "1.25", Quantity.format(1.25, Unit["kg"])
    assert_equal "12.5", Quantity.format(12.5, Unit["ml"])
    assert_equal "333", Quantity.format(1000/3r, Unit["g"])
  end

  test "falls back to decimals when no kitchen fraction is close" do
    assert_equal "0.43", Quantity.format(0.43, Unit["cup"])
  end

  test "values just under a whole number round up instead of showing 1/1" do
    assert_equal "1", Quantity.format(0.999, Unit["cup"])
    assert_equal "3", Quantity.format(2.98, nil)
  end
end
