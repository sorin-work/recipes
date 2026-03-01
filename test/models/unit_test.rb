require "test_helper"

class UnitTest < ActiveSupport::TestCase
  test "finds units by any spelling" do
    assert_equal "tbsp", Unit.find("Tablespoons").code
    assert_equal "tbsp", Unit.find("tbsp.").code
    assert_equal "g", Unit.find("grams").code
    assert_equal "l", Unit.find("Litres").code
    assert_equal "can", Unit.find("tins").code
    assert_equal "fl oz", Unit.find("fl. oz").code
    assert_nil Unit.find("handfulls")
    assert_nil Unit.find("")
  end

  test "single letters are case sensitive" do
    assert_equal "tsp", Unit.find("t").code
    assert_equal "tbsp", Unit.find("T").code
  end

  test "mass and volume convert through their base units" do
    assert_equal 1500, Unit["kg"].to_base(1.5)
    assert_equal 2, Unit["l"].from_base(2000)
    assert Unit["kg"].convertible_to?(Unit["oz"])
    assert Unit["cup"].convertible_to?(Unit["ml"])
    assert_not Unit["cup"].convertible_to?(Unit["g"])
  end

  test "counted units only convert to themselves" do
    assert Unit["can"].convertible_to?(Unit["can"])
    assert_not Unit["can"].convertible_to?(Unit["clove"])
    assert_not Unit["can"].convertible_to?(Unit["g"])
  end

  test "labels are plural above one" do
    assert_equal "cup", Unit["cup"].label_for(1)
    assert_equal "cups", Unit["cup"].label_for(1.5)
    assert_equal "cup", Unit["cup"].label_for(0.5)
    assert_equal "g", Unit["g"].label_for(250)
  end

  test "three teaspoons are exactly one tablespoon and sixteen tablespoons a cup" do
    assert_equal Unit["tbsp"].factor, Unit["tsp"].factor * 3
    assert_equal Unit["cup"].factor, Unit["tbsp"].factor * 16
  end
end
