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
end
