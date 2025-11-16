require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "new" do
    get new_registration_path
    assert_response :success
    assert_select "form input[name='user[name]']"
  end

  test "signing up creates an account and signs in" do
    assert_difference -> { User.count } do
      post registration_path, params: { user: {
        name: "Sam Cook", email_address: "Sam@Example.com", password: "long-password", password_confirmation: "long-password"
      } }
    end

    assert_redirected_to root_path
    assert cookies[:session_id]
    assert_equal "sam@example.com", User.last.email_address
  end

  test "shows what is wrong" do
    assert_no_difference -> { User.count } do
      post registration_path, params: { user: {
        name: "", email_address: "one@example.com", password: "short", password_confirmation: "nope"
      } }
    end

    assert_response :unprocessable_entity
    assert_select ".form-errors li", minimum: 3
  end
end
