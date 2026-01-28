require "test_helper"

class DurationParserTest < ActiveSupport::TestCase
  def minutes(text) = DurationParser.minutes(text)

  test "minutes and hours" do
    assert_equal 15, minutes("15 minutes")
    assert_equal 15, minutes("15 mins")
    assert_equal 60, minutes("1 hour")
    assert_equal 75, minutes("1 hr 15 mins")
    assert_equal 75, minutes("1h15m")
    assert_equal 90, minutes("1 1/2 hours")
    assert_equal 90, minutes("1.5 hrs")
  end

  test "a bare number is minutes" do
    assert_equal 20, minutes("20")
  end

  test "iso 8601 durations from recipe sites" do
    assert_equal 45, minutes("PT45M")
    assert_equal 80, minutes("PT1H20M")
  end

  test "nonsense" do
    assert_nil minutes("overnight")
    assert_nil minutes("")
    assert_nil minutes(nil)
  end

  test "minutes after hours without a unit" do
    assert_equal 75, minutes("1 hr 15")
    assert_equal 135, minutes("2 hours 15")
  end
end
