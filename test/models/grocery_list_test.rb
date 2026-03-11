require "test_helper"

class GroceryListTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @week = Week.current
    @user.pantry_items.delete_all
  end

  def plan(recipe, servings: nil, day: 0, meal: "dinner")
    @user.meal_plan_entries.create!(recipe: recipe, on: @week.start + day, meal: meal, servings: servings)
  end

  def list
    GroceryList.new(@user, @week)
  end

  def item(name)
    list.items.find { |item| item.key == name } || flunk("no #{name} on the list")
  end

  test "empty without a plan" do
    assert list.empty?
  end

  test "lists the ingredients of planned meals" do
    plan recipes(:pasta)
    assert_equal [ "garlic", "olive oil", "spaghetti" ], list.items.map(&:name)
    assert_equal "200 g", item("spaghetti").amount_text
  end

  test "scales to the servings planned" do
    plan recipes(:pasta), servings: 3
    assert_equal "300 g", item("spaghetti").amount_text
    assert_equal "3 cloves", item("garlic").amount_text
  end

  test "adds up the same ingredient across meals" do
    plan recipes(:pasta), day: 0
    plan recipes(:pasta), day: 2
    assert_equal "400 g", item("spaghetti").amount_text
    assert_equal [ "Garlic Spaghetti" ], item("spaghetti").recipes
  end

  test "ignores meals outside the week" do
    plan recipes(:pasta), day: 7
    assert list.empty?
  end

  test "ingredients without a quantity are as needed" do
    plan recipes(:pancakes)
    assert_equal "as needed", item("salt").amount_text
    assert item("salt").as_needed?
  end

  test "adds up quantities written in different units" do
    plan recipes(:pasta)
    @user.recipes.create!(title: "More pasta", servings: 2, ingredients_text: "1 kg spaghetti\n1 tsp olive oil")
      .then { |recipe| plan recipe, day: 1 }

    assert_equal "1.2 kg", item("spaghetti").amount_text
    assert_equal "2 1/3 tbsp", item("olive oil").amount_text
  end

  test "keeps amounts that can't be added separately" do
    plan recipes(:pasta)
    @user.recipes.create!(title: "Garlic bread", servings: 2, ingredients_text: "1 head garlic").then { |r| plan r, day: 1 }

    assert_equal "2 cloves + 1 head", item("garlic").amount_text
  end

  test "sections follow the shop" do
    plan recipes(:pancakes)
    plan recipes(:pasta), day: 1

    sections = list.sections.to_h { |aisle, items| [ aisle, items.map(&:name) ] }
    assert_equal [ "egg", "milk" ], sections["dairy & eggs"]
    assert_includes sections["pantry"], "plain flour"
    assert_includes sections["produce"], "garlic"
    assert_equal Aisle::ORDER.select { |aisle| sections.key?(aisle) }, sections.keys
  end

  test "remembers ticked items for the week" do
    plan recipes(:pasta)
    @user.grocery_checks.create!(week_start: @week.start, item_key: "spaghetti")

    assert item("spaghetti").checked
    assert_not item("garlic").checked
  end

  test "staples in the pantry come off the list" do
    plan recipes(:pancakes)
    @user.pantry_items.create!(name: "Salt")

    assert_includes list.in_pantry.map(&:name), "salt"
    assert_not_includes list.to_buy.map(&:name), "salt"
  end

  test "pantry amounts are subtracted" do
    plan recipes(:pasta), servings: 4
    @user.pantry_items.create!(name: "spaghetti", amount_text: "150 g")

    assert_equal "250 g", item("spaghetti").amount_text
    assert_includes list.to_buy.map(&:name), "spaghetti"
  end

  test "enough in the pantry moves the item off the list" do
    plan recipes(:pasta)
    @user.pantry_items.create!(name: "spaghetti", amount_text: "500 g")

    assert_includes list.in_pantry.map(&:name), "spaghetti"
  end

  test "plain text version" do
    plan recipes(:pasta)
    text = list.to_text

    assert_match(/\AGrocery list for /, text)
    assert_includes text, "[ ] spaghetti - 200 g"
  end
end
