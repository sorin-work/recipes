require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup { @user = users(:one) }

  test "new" do
    get new_session_path
    assert_response :success
  end

  test "create with valid credentials" do
    post session_path, params: { email_address: @user.email_address, password: "password123" }

    assert_redirected_to root_path
    assert cookies[:session_id]
  end

  test "create with an email in a different case" do
    post session_path, params: { email_address: " ONE@example.com", password: "password123" }

    assert_redirected_to root_path
  end

  test "create with invalid credentials" do
    post session_path, params: { email_address: @user.email_address, password: "wrong" }

    assert_redirected_to new_session_path
    assert_nil cookies[:session_id]
  end

  test "returns to the page that asked for sign in" do
    get recipes_path
    assert_redirected_to new_session_path

    post session_path, params: { email_address: @user.email_address, password: "password123" }
    assert_redirected_to recipes_url
  end

  test "signed in users skip the form" do
    sign_in_as @user
    get new_session_path
    assert_redirected_to root_path
  end

  test "destroy" do
    sign_in_as(@user)

    delete session_path

    assert_redirected_to new_session_path
    assert_empty cookies[:session_id]
  end
end
