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
end
