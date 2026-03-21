require "test_helper"

class AccountsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in_as @user
  end

  test "edit" do
    get edit_account_path
    assert_response :success
    assert_select "input[name='user[name]'][value=?]", "Olive Oyl"
  end

  test "update name and email" do
    patch account_path, params: { user: { name: "Olive", email_address: "olive@example.com" } }
    assert_redirected_to edit_account_path
    assert_equal "olive@example.com", @user.reload.email_address
  end

  test "email already in use" do
    patch account_path, params: { user: { name: "Olive", email_address: "two@example.com" } }
    assert_response :unprocessable_entity
    assert_equal "one@example.com", @user.reload.email_address
  end

  test "delete with the right password" do
    assert_difference -> { User.count }, -1 do
      delete account_path, params: { password: "password123" }
    end
    assert_redirected_to new_session_path
  end

  test "delete with the wrong password does nothing" do
    assert_no_difference -> { User.count } do
      delete account_path, params: { password: "nope" }
    end
    assert_redirected_to edit_account_path
  end
end
