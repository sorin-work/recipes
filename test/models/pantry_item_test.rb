require "test_helper"

class PantryItemTest < ActiveSupport::TestCase
  test "amount text sets quantity and unit" do
    item = PantryItem.new(name: "rice", amount_text: "1.5 kg")
    assert_equal 1.5, item.quantity
    assert_equal "kg", item.unit
    assert_equal "1.5 kg", item.amount

    item.amount_text = "2 cans"
    assert_equal "can", item.unit

    item.amount_text = ""
    assert item.staple?
    assert_nil item.amount
  end

  test "rejects units it doesn't know" do
    item = users(:one).pantry_items.new(name: "rice", amount_text: "2 bags")
    assert_not item.valid?
    assert item.errors[:unit].any?
  end

  test "names are unique per user" do
    assert_not users(:one).pantry_items.new(name: "Salt").valid?
    assert users(:two).pantry_items.new(name: "Salt").valid?
  end

  test "names match the way the grocery list matches them" do
    assert_not users(:one).pantry_items.new(name: "salts").valid?
    assert_equal "egg", PantryItem.new(name: "Large Eggs").tap(&:validate).name_key
  end
end
