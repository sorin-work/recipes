require "test_helper"

class AmountTest < ActiveSupport::TestCase
  def amount(quantity, unit = nil)
    Amount.from(quantity, unit)
  end

  test "adds grams and kilos" do
    assert_equal "1.5 kg", (amount(500, "g") + amount(1, "kg")).to_s
    assert_equal "750 g", (amount(500, "g") + amount(250, "g")).to_s
  end

  test "adds millilitres and litres" do
    assert_equal "1.2 l", (amount(700, "ml") + amount(0.5, "l")).to_s
    assert_equal "300 ml", (amount(100, "ml") + amount(200, "ml")).to_s
  end

  test "spoons and cups stay in spoons and cups" do
    assert_equal "1/4 cup", (amount(2, "tbsp") + amount(2, "tbsp")).to_s
    assert_equal "2 tbsp", (amount(1, "tbsp") + amount(1, "tbsp")).to_s
    assert_equal "1 1/2 cups", (amount(1, "cup") + amount(8, "tbsp")).to_s
    assert_equal "2 tsp", (amount(1, "tsp") + amount(1, "tsp")).to_s
  end

  test "mixing metric and cup measures gives millilitres" do
    assert_equal "487 ml", (amount(250, "ml") + amount(1, "cup")).to_s
  end

  test "counted units add up with the same unit only" do
    assert_equal "3 cans", (amount(1, "can") + amount(2, "tin")).to_s
    assert_not amount(1, "can").compatible?(amount(1, "clove"))
    assert_raises(ArgumentError) { amount(1, "can") + amount(100, "g") }
  end

  test "plain numbers" do
    assert_equal "3", (amount(1) + amount(2)).to_s
    assert_equal "1 1/2", amount(1.5).to_s
  end

  test "subtracting never goes below zero" do
    assert_equal "200 g", (amount(500, "g") - amount(300, "g")).to_s
    assert (amount(500, "g") - amount(1, "kg")).zero?
  end

  test "three teaspoons make a tablespoon" do
    assert_equal "1 tbsp", (amount(1, "tsp") + amount(2, "tsp")).to_s
    assert_equal "1/4 cup", (amount(3, "tbsp") + amount(3, "tsp")).to_s
  end
end
