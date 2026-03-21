require "test_helper"

class PasswordChangesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in_as @user
  end

  test "change password and sign out other sessions" do
    mine = Current.session
    other = @user.sessions.create!

    patch password_change_path, params: {
      current_password: "password123", user: { password: "a-better-password", password_confirmation: "a-better-password" }
    }

    assert_redirected_to edit_account_path
    assert @user.reload.authenticate("a-better-password")
    assert_not Session.exists?(other.id)
    assert Session.exists?(mine.id)
  end

  test "wrong current password" do
    patch password_change_path, params: {
      current_password: "wrong", user: { password: "a-better-password", password_confirmation: "a-better-password" }
    }
    assert_redirected_to edit_account_path
    assert @user.reload.authenticate("password123")
  end

  test "new password too short" do
    patch password_change_path, params: { current_password: "password123", user: { password: "short", password_confirmation: "short" } }
    assert_match(/too short/, flash[:alert])
  end
end
