require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "downcases and strips email_address" do
    user = User.new(email_address: " DOWNCASED@EXAMPLE.COM ")
    assert_equal("downcased@example.com", user.email_address)
  end

  test "requires a valid email address" do
    user = User.new(name: "Sam", email_address: "not-an-email", password: "long-enough")
    assert_not user.valid?
    assert_includes user.errors[:email_address], "is invalid"
  end

  test "email addresses are unique regardless of case" do
    user = User.new(name: "Sam", email_address: "ONE@example.com", password: "long-enough")
    assert_not user.valid?
    assert_includes user.errors[:email_address], "has already been taken"
  end

  test "passwords need at least 8 characters" do
    user = User.new(name: "Sam", email_address: "sam@example.com", password: "short")
    assert_not user.valid?
    assert user.errors[:password].any?
  end

  test "requires a name and squishes it" do
    user = User.new(name: "  Sam   Smith ", email_address: "sam@example.com", password: "long-enough")
    assert user.valid?
    assert_equal "Sam Smith", user.name
    assert_equal "Sam", user.first_name

    user.name = " "
    assert_not user.valid?
  end

  test "deleting a user deletes their recipes, plan and pantry" do
    user = users(:one)
    user.meal_plan_entries.create!(recipe: recipes(:pasta), on: Date.current, meal: "dinner")

    assert_difference -> { Recipe.count } => -2, -> { MealPlanEntry.count } => -1, -> { PantryItem.count } => -2 do
      user.destroy!
    end
  end
end
