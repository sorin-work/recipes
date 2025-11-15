require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "downcases and strips email_address" do
    user = User.new(email_address: " DOWNCASED@EXAMPLE.COM ")
    assert_equal("downcased@example.com", user.email_address)
  end

  test "requires a name and squishes it" do
    user = User.new(name: "  Sam   Smith ", email_address: "sam@example.com", password: "long-enough")
    assert user.valid?
    assert_equal "Sam Smith", user.name
    assert_equal "Sam", user.first_name

    user.name = " "
    assert_not user.valid?
  end
end
