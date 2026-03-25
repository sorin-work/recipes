require "test_helper"

class HealthControllerTest < ActionDispatch::IntegrationTest
  test "up without signing in" do
    get health_check_path
    assert_response :success
    assert_equal({ "status" => "ok", "database" => "ok" }, response.parsed_body)
  end
end
