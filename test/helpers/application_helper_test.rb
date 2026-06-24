require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  test "duration" do
    assert_equal "45 min", duration(45)
    assert_equal "1 hr", duration(60)
    assert_equal "1 hr 15 min", duration(75)
    assert_equal "0 min", duration(0)
    assert_nil duration(nil)
  end
end
