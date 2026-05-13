require "test_helper"

class IngredientParserTest < ActiveSupport::TestCase
  def parse(line)
    IngredientParser.parse(line)
  end

  test "quantity, unit and name" do
    result = parse("200 g plain flour")
    assert_equal 200, result.quantity
    assert_equal "g", result.unit
    assert_equal "plain flour", result.name
    assert_nil result.note
  end

  test "units written out, abbreviated or glued to the number" do
    assert_equal "tbsp", parse("2 tablespoons olive oil").unit
    assert_equal "tbsp", parse("2 Tbsp. olive oil").unit
    assert_equal "kg", parse("1kg potatoes").unit
    assert_equal "ml", parse("250ml milk").unit
    assert_equal "fl oz", parse("4 fl oz cream").unit
  end

  test "words that start like a unit are part of the name" do
    result = parse("2 large eggs")
    assert_nil result.unit
    assert_equal "large eggs", result.name

    assert_equal "lemons", parse("2 lemons").name
    assert_nil parse("1 cucumber").unit
  end

  test "text after a comma is a note" do
    result = parse("1 onion, finely chopped")
    assert_equal 1, result.quantity
    assert_nil result.unit
    assert_equal "onion", result.name
    assert_equal "finely chopped", result.note
  end

  test "a trailing bracket is a note" do
    result = parse("50 g butter (softened)")
    assert_equal "butter", result.name
    assert_equal "softened", result.note
  end

  test "drops 'of' after the unit" do
    assert_equal "flour", parse("1 cup of flour").name
  end

  test "lines without a quantity" do
    result = parse("salt and pepper, to taste")
    assert_nil result.quantity
    assert_nil result.unit
    assert_equal "salt and pepper", result.name
    assert_equal "to taste", result.note
  end

  test "strips list bullets" do
    assert_equal "garlic", parse("- 2 cloves garlic").name
    assert_equal "garlic", parse("• 2 cloves garlic").name
  end

  test "blank lines are skipped" do
    assert_nil parse("   ")
  end

  test "package sizes in brackets go in the note" do
    result = parse("1 (400 g) can chopped tomatoes")
    assert_equal 1, result.quantity
    assert_equal "can", result.unit
    assert_equal "chopped tomatoes", result.name
    assert_equal "400 g", result.note
  end

  test "a capital T is a tablespoon and a small t a teaspoon" do
    assert_equal "tbsp", parse("1 T sugar").unit
    assert_equal "tsp", parse("1 t salt").unit
    assert_equal "sugar", parse("1 T sugar").name
  end

  test "'a' or 'an' means one" do
    result = parse("a pinch of salt")
    assert_equal 1, result.quantity
    assert_equal "pinch", result.unit
    assert_equal "salt", result.name

    assert_equal 1, parse("an onion").quantity
    assert_nil parse("a few sprigs of thyme").quantity
  end

  test "a line ending in a colon is a heading" do
    result = parse("For the sauce:")
    assert result.heading?
    assert_equal "For the sauce", result.name
    assert_not parse("2 cups flour").heading?
  end
end
